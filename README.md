# IndexNow WP Auto Submit

This script automates the submission of WordPress URLs to the IndexNow API for multiple sites at once. While simple, it's a huge time and cost saver for managing SEO on a lot of WP blogs. There are plugins that do the same, but those need to be installed and configured individually for each site. This script eliminates that need—just paste your API key, set the root directory, and it handles everything else automatically.

## Features:
- Automatically scans all WordPress sites within the root directory.
- Creates the required IndexNow key file for each domain.
- Gathers all URLs from each WordPress site and submits them to IndexNow.
- Fully automated—no per-site setup needed after initial config.

## Setup:
1. Set your `API_KEY` and `ROOT_DIR` in the script.
2. Ensure that all your WordPress sites are located within `ROOT_DIR`.
3. Run the script.

## Usage:
1. Download and place the script in a convenient location.
2. Set the appropriate variables:
   ```bash
   API_KEY="yourkey"
   ROOT_DIR="/your/web/root"
   ```
3. Run the script using:
   ```bash
   ./indexnow-submit.sh
   ```

## Future Plans:
- For now, this script covers everything I need, but I may add more features later.
