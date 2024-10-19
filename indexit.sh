#!/bin/bash

# Variables
API_KEY="yourkey"
ROOT_DIR="/your/web/root"
API_URL="https://api.indexnow.org/indexnow"
KEY_FILE_NAME="${API_KEY}.txt"

# Function to generate the key file
generate_key_file() {
    DOMAIN=$1
    DOMAIN_PATH=$2
    KEY_FILE_PATH="${DOMAIN_PATH}/${KEY_FILE_NAME}"

    # Create key file
    echo "${API_KEY}" > "${KEY_FILE_PATH}"

    # Ensure key file is publicly accessible
    chmod 644 "${KEY_FILE_PATH}"

    echo "Key file created at ${KEY_FILE_PATH}"
}

# Function to gather all URLs from a WP site
get_wp_urls() {
    DOMAIN_PATH=$1
    DOMAIN=$2
    URL_LIST=()

    # Get all post and page URLs
    WP_POSTS_DIR="${DOMAIN_PATH}/wp-content/uploads"
    
    if [[ -d "${WP_POSTS_DIR}" ]]; then
        for post in $(find "${DOMAIN_PATH}/wp-content/uploads" -name "*.php"); do
            URL="${DOMAIN}${post#${DOMAIN_PATH}}"
            URL_LIST+=("${URL}")
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
        echo "No URLs found for ${DOMAIN}"
        return
    fi

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

    # Submit URLs via curl
    RESPONSE=$(curl -s -X POST -H "Content-Type: application/json; charset=utf-8" -d "${PAYLOAD}" ${API_URL})

    echo "Submitted URLs for ${DOMAIN}:"
    echo "${RESPONSE}"
}

# Main script to process each WordPress site in the ROOT_DIR
for domain_path in $(find "$ROOT_DIR" -name "wp-config.php"); do
    DOMAIN_DIR=$(dirname "${domain_path}")
    DOMAIN=$(grep "WP_HOME" "${DOMAIN_DIR}/wp-config.php" | cut -d "'" -f 4)

    if [[ -z "${DOMAIN}" ]]; then
        echo "Could not determine domain for path ${DOMAIN_DIR}"
        continue
    fi

    # Generate the key file and submit URLs
    generate_key_file "$DOMAIN" "$DOMAIN_DIR"
    submit_urls "$DOMAIN" "$DOMAIN_DIR"
done

# Log final status
echo "IndexNow URL submission completed."
