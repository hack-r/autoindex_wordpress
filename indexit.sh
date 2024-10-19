#!/bin/bash

# Variables
API_KEY="bb725095a85744d3a5023edb81d6b5c0"
ROOT_DIR="/home/datacmti"
API_URL="https://api.indexnow.org/indexnow"
KEY_FILE_NAME="${API_KEY}.txt"
LINE_BREAK="==============================================================="

# Greeting
echo -e "\n$LINE_BREAK"
echo -e " 🚀 Welcome to the WordPress IndexNow Automation Script! 🚀"
echo -e "$LINE_BREAK\n"
echo "This script automatically indexes all WP posts and pages using IndexNow."
echo "API Key: $API_KEY"
echo -e "Root directory for WordPress sites: $ROOT_DIR\n"
echo "Let's begin!"

# Function to generate the key file
generate_key_file() {
    DOMAIN=$1
    DOMAIN_PATH=$2
    KEY_FILE_PATH="${DOMAIN_PATH}/${KEY_FILE_NAME}"

    echo -e "\n$LINE_BREAK"
    echo -e "🔑 Generating key file for domain: $DOMAIN"
    echo -e "$LINE_BREAK"

    # Create key file
    echo "${API_KEY}" > "${KEY_FILE_PATH}"

    # Ensure key file is publicly accessible
    chmod 644 "${KEY_FILE_PATH}"

    echo "Key file created at ${KEY_FILE_PATH} with key: ${API_KEY}"
}

# Function to gather all URLs from a WP site
get_wp_urls() {
    DOMAIN_PATH=$1
    DOMAIN=$2
    URL_LIST=()

    echo -e "\n$LINE_BREAK"
    echo -e "🌐 Gathering URLs for domain: $DOMAIN"
    echo -e "$LINE_BREAK"

    # Find all post URLs (simplified for demo purposes; adapt as needed)
    for post in $(find "${DOMAIN_PATH}/wp-content" -name "*.php" -o -name "*.html" -o -name "*.htm"); do
        URL="${DOMAIN}${post#${DOMAIN_PATH}}"
        URL_LIST+=("${URL}")
    done

    if [[ ${#URL_LIST[@]} -eq 0 ]]; then
        echo "⚠️ No URLs found for domain: $DOMAIN"
    else
        echo "✅ Found URLs for $DOMAIN:"
        for url in "${URL_LIST[@]}"; do
            echo "   - $url"
        done
    fi

    echo "${URL_LIST[@]}"
}

# Function to submit URLs to IndexNow
submit_urls() {
    DOMAIN=$1
    DOMAIN_PATH=$2
    URL_LIST=($(get_wp_urls "$DOMAIN_PATH" "$DOMAIN"))

    if [[ ${#URL_LIST[@]} -eq 0 ]]; then
        echo "❌ No URLs found for $DOMAIN, skipping submission."
        return
    fi

    echo -e "\n$LINE_BREAK"
    echo -e "🚀 Submitting URLs for domain: $DOMAIN to IndexNow"
    echo -e "$LINE_BREAK"

    # Create JSON payload
    URL_JSON=$(printf '"%s",' "${URL_LIST[@]}" | sed 's/,$//')
    PAYLOAD=$(cat <<EOF
{
  "host": "${DOMAIN}",
  "key": "${API_KEY}",
  "keyLocation": "${DOMAIN}/${KEY_FILE_NAME}",
  "urlList": [
    ${URL_JSON}
  ]
}
EOF
    )

    echo "Payload for $DOMAIN:"
    echo "$PAYLOAD"

    # Submit URLs via curl
    RESPONSE=$(curl -s -X POST -H "Content-Type: application/json; charset=utf-8" -d "${PAYLOAD}" ${API_URL})

    echo -e "Submission response for ${DOMAIN}:"
    echo "${RESPONSE}"
}

# Main script to process each WordPress site in the ROOT_DIR
for domain_path in $(find "$ROOT_DIR" -name "wp-config.php"); do
    DOMAIN_DIR=$(dirname "${domain_path}")
    
    # Check if the directory contains wp-admin and wp-includes (indicating a WP install)
    if [[ -d "${DOMAIN_DIR}/wp-admin" && -d "${DOMAIN_DIR}/wp-includes" ]]; then
        
        # Try to extract the domain from wp-config.php or fallback to directory name
        DOMAIN=$(grep "WP_HOME" "${DOMAIN_DIR}/wp-config.php" | cut -d "'" -f 4)
        if [[ -z "${DOMAIN}" ]]; then
            DOMAIN=$(basename "${DOMAIN_DIR}")
            echo "ℹ️  No WP_HOME found. Using folder name as domain: $DOMAIN"
        fi

        echo -e "\n$LINE_BREAK"
        echo -e "🔍 Processing WordPress site at: $DOMAIN_DIR"
        echo -e "$LINE_BREAK"

        # Generate the key file and submit URLs
        generate_key_file "$DOMAIN" "$DOMAIN_DIR"
        submit_urls "$DOMAIN" "$DOMAIN_DIR"

    else
        echo "❌ Skipping non-WordPress folder: $DOMAIN_DIR (no wp-admin/wp-includes found)"
    fi
done

# Final log status
echo -e "\n$LINE_BREAK"
echo -e "✅ IndexNow URL submission completed successfully!"
echo -e "$LINE_BREAK\n"
