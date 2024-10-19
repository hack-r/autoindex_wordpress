# WordPress Sitemap Generation and IndexNow Auto-submission

This script automates the submission of WordPress URLs to the IndexNow API for multiple sites at once. It intelligently validates the existing sitemaps and only regenerates them when necessary, ensuring that your SEO data remains accurate and up-to-date. There’s no need to install individual plugins on each WordPress site; the script handles everything for you across multiple sites automatically.

## Major Features:
- **Automatic WordPress Detection**: Scans directories for `wp-config.php` files to ensure only actual WordPress sites are processed.
- **Sitemap Validation**: Compares existing sitemaps with database data and only regenerates if the sitemap is missing, corrupted, or outdated.
- **Database URL Extraction**: Retrieves URLs directly from the WordPress database (`wp_posts` table) to ensure accurate URL listings.
- **Efficient URL Submission**: Batches URL submissions to the IndexNow API for more efficient processing.
- **Error Handling**: Provides clear error messages for any issues encountered (e.g., missing sitemaps, database connection errors).
- **Minimizes Redundant Processing**: Ensures that valid sitemaps are not overwritten and inappropriate directories are not checked.

## Setup:

1. **API Key**: Ensure you have an IndexNow API key. Set it in the script where `API_KEY` is defined:
   ```bash
   API_KEY="yourkey"
   ```
   
2. **WordPress Root Directory**: Set the `ROOT_DIR` variable to the root directory where your WordPress installations are located:
   ```bash
   ROOT_DIR="/path/to/wordpress/sites"
   ```

3. **Permissions**: Ensure the script has the necessary permissions to access the WordPress directories and databases.

4. **Run the Script**:
   ```bash
   ./indexit.sh
   ```

## Usage:

1. **Run the Script**: Once your API key and root directory are set, simply run the script from your terminal:
   ```bash
   ./indexit.sh
   ```

2. **Logging**: The script logs all submissions and errors to a file (`/var/log/indexnow_submission.log`) for easy review.

## Example:

If you have several WordPress sites located in `/home/user/public_html/`, the script will automatically:
- Locate all `wp-config.php` files,
- Extract URLs from the database,
- Validate the existing `sitemap.xml` files (if any),
- Submit valid URLs to IndexNow.

## Intelligent Sitemap Handling:

The script checks for the presence and validity of the `sitemap.xml` file. If a valid sitemap already exists, it skips regeneration. If the sitemap is missing or outdated, the script generates a new one based on the database URLs.

## Avoids Inappropriate Directories:

The script ensures that only valid WordPress directories are checked (directories containing `wp-config.php`). It avoids unnecessary or inappropriate directories, such as `ssl`, `.ssh`, or `logs`, to improve performance and accuracy.

## Room for Future Enhancements:

- **Advanced Logging**: More detailed submission results and potential API rate limit handling.
- **Enhanced Error Reporting**: More specific error diagnostics to make troubleshooting easier.
- **Additional CMS Support**: Potential support for other CMS platforms in the future.

Note that this was a quick win for my personal development work, but it's not a project I plan to spend time on moving forward. Feel free to fork it and take over. 

## Final Thoughts:

This script provides an efficient way to manage multiple WordPress sites’ SEO efforts in one go. It's ideal for anyone managing multiple WordPress installations who wants to automate URL submissions without configuring plugins on each individual site.
