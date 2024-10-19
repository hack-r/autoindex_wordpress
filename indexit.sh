#!/bin/bash

API_KEY=""
BATCH_SIZE=50
LINE_BREAK="==============================================================="
LOG_FILE="/var/log/indexnow_submission.log"

# Function to check if a sitemap exists and is valid
check_sitemap() {
    sitemap_path="$1/sitemap.xml"
    domain="$2"
    wp_config="$3"

    # Extract database credentials from wp-config.php
    DB_NAME=$(grep "DB_NAME" "$wp_config" | cut -d "'" -f 4)
    DB_USER=$(grep "DB_USER" "$wp_config" | cut -d "'" -f 4)
    DB_PASSWORD=$(grep "DB_PASSWORD" "$wp_config" | cut -d "'" -f 4)
    DB_HOST=$(grep "DB_HOST" "$wp_config" | cut -d "'" -f 4)
    table_prefix=$(grep "table_prefix" "$wp_config" | cut -d "'" -f 2)

    # Query the database for published post URLs
    db_urls=$(mysql -u "$DB_USER" -p"$DB_PASSWORD" -D "$DB_NAME" -h "$DB_HOST" -e \
        "SELECT CONCAT('https://$domain/', post_name) FROM ${table_prefix}posts WHERE post_status = 'publish' AND post_type IN ('post', 'page');" \
        | tail -n +2)

    if [ -z "$db_urls" ]; then
        echo "⚠️  No URLs found in the database for $domain."
        return 1
    fi

    # If sitemap exists, check if it's valid
    if [ -f "$sitemap_path" ]; then
        sitemap_urls=$(grep -oP '(?<=<loc>)[^<]+' "$sitemap_path")

        if [ "$(echo "$sitemap_urls" | wc -l)" -eq "$(echo "$db_urls" | wc -l)" ]; then
            common_count=$(comm -12 <(echo "$sitemap_urls" | sort) <(echo "$db_urls" | sort) | wc -l)
            if [ "$common_count" -ge "$(echo "$db_urls" | wc -l)" ]; then
                echo "✅ Sitemap for $domain is valid and up to date."
                return 0
            fi
        fi
    fi

    echo "❌ Sitemap for $domain is missing, corrupted, or outdated. Generating a new one..."
    generate_sitemap "$1" "$domain" "$db_urls"
}

# Function to generate a sitemap based on database content
generate_sitemap() {
    sitemap_path="$1/sitemap.xml"
    domain="$2"
    db_urls="$3"

    echo "🌐 Generating sitemap for domain: $domain"
    echo '<?xml version="1.0" encoding="UTF-8"?>' > "$sitemap_path"
    echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> "$sitemap_path"

    for url in $db_urls; do
        echo "<url><loc>$url</loc></url>" >> "$sitemap_path"
    done

    echo '</urlset>' >> "$sitemap_path"
    echo "✅ Sitemap generated at $sitemap_path"
}

# Function to submit URLs to IndexNow API
submit_to_indexnow() {
    domain="$1"
    urls="$2"
    url_count=$(echo "$urls" | wc -l)

    echo "📝 Submitting $url_count URLs for $domain..."
    
    for batch in $(seq 0 $BATCH_SIZE $url_count); do
        batch_urls=$(echo "$urls" | tail -n +$batch | head -n $BATCH_SIZE)
        json_payload=$(echo "$batch_urls" | awk '{print "\"" $0 "\""}' | paste -sd "," -)

        response=$(curl -s -X POST "https://api.indexnow.org/indexnow?urlset=https://$domain&key=$API_KEY" \
            -H "Content-Type: application/json" \
            -d '{"siteUrl": "https://'$domain'", "urlList": ['$json_payload']}')

        if [[ "$response" == *"error"* ]]; then
            echo "❌ Error submitting URLs for $domain: $response"
        else
            echo "✅ Successfully submitted URLs for $domain."
        fi
    done
}

# Function to process each WordPress site
process_wordpress() {
    site_dir="$1"
    domain=$(basename "$site_dir")
    wp_config="$site_dir/wp-config.php"

    echo -e "\n$LINE_BREAK"
    echo "🔍 Processing WordPress site at: $site_dir"
    echo -e "$LINE_BREAK"

    if [ ! -f "$wp_config" ]; then
        echo "❌ No wp-config.php found for $site_dir. Skipping..."
        return 1
    fi

    # Check for existing sitemap
    sitemap_path="$site_dir/sitemap.xml"
    if [ -f "$sitemap_path" ]; then
        check_sitemap "$site_dir" "$domain" "$wp_config"
    else
        echo "❌ No sitemap found for $domain. Generating one..."
        check_sitemap "$site_dir" "$domain" "$wp_config"
    fi

    # Submit sitemap URLs to IndexNow
    if [ -f "$sitemap_path" ]; then
        sitemap_urls=$(grep -oP '(?<=<loc>)[^<]+' "$sitemap_path")
        if [ -n "$sitemap_urls" ]; then
            submit_to_indexnow "$domain" "$sitemap_urls"
        else
            echo "⚠️  No URLs found in the sitemap for $domain."
        fi
    fi
}

# Main script execution
echo "🔍 Starting IndexNow URL submission process..."

for dir in $(find /home/datacmti -mindepth 1 -maxdepth 2 -type d); do
    if [ -f "$dir/wp-config.php" ]; then
        process_wordpress "$dir"
    else
        echo "❌ No wp-config.php found for $dir. Skipping..."
    fi
done

echo -e "$LINE_BREAK"
echo "✅ IndexNow URL submission completed!"
echo -e "$LINE_BREAK"
