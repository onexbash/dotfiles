#!/usr/bin/env bash
# -- -- -- -- -- -- -- -- -- -- #
# -- GitHub Banner Generator -- #
# -- -- -- -- -- -- -- -- -- -- #

# Ensure we're running in Bash
if [ -z "$BASH_VERSION" ]; then
    echo -e "This script must be run with Bash"
    exit 1
fi

# Variables
THIS_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Load helper script
if [ -f "$THIS_DIR/scripts/helper.sh" ]; then
    source "$THIS_DIR/scripts/helper.sh"
    load_stylings && set_modes
fi

# Function to display the title and description
display_info() {
    echo -e "${C_YELLOW}============================${C_RESET}"
    echo -e "${C_GREEN}  GitHub Social Image Generator  ${C_RESET}"
    echo -e "${C_YELLOW}============================${C_RESET}"
    echo -e "This tool automatically generates beautiful social media images for your GitHub repositories."
    echo -e "Created by: ${C_CYAN}github.com/mahendraplus - Mahendra Mali${C_RESET}"
    echo -e "${C_YELLOW}============================${C_RESET}"
}

# Parse command-line arguments
while getopts ":u:r:" opt; do
    case $opt in
        u) USERNAME="$OPTARG" ;;
        r) REPO_NAME="$OPTARG" ;;
        \?) echo -e "${C_RED}Invalid option: -$OPTARG${C_RESET}" >&2; exit 1 ;;
    esac
done

# Display tool information
display_info

# Check if username is provided
if [ -z "$USERNAME" ]; then
    read -r -p "Please enter your GitHub username: " USERNAME
fi

# If a repository name is not provided, prompt for one
if [ -z "$REPO_NAME" ]; then
    read -r -p "Please enter a repository name (or leave blank for all): " REPO_NAME
fi

# Create the directory if it doesn't exist
mkdir -p "./"

# Function to download images for a specific repository
download_images() {
    local repo_name="$1"
    echo -e "${C_BLUE}Processing repository: $repo_name${C_RESET}"

    # URL to fetch images from the API for the current repository
    API_URL="https://lpf64gdwdb.execute-api.us-east-1.amazonaws.com/?repo=https://github.com/$USERNAME/$repo_name"

    # Fetching image URLs with error handling
    if ! response=$(curl -s --fail "$API_URL"); then
        echo -e "${C_RED}Failed to fetch images for $repo_name${C_RESET}"
        return 1
    fi

    # Check if response is valid JSON
    if ! jq -e . >/dev/null 2>&1 <<<"$response"; then
        echo -e "${C_RED}Invalid API response for $repo_name${C_RESET}"
        return 1
    fi

    # Extract image URLs safely
    if ! img_urls=$(jq -r '.[]?' <<<"$response"); then
        echo -e "${C_RED}Failed to parse image URLs for $repo_name${C_RESET}"
        return 1
    fi

    # Initialize a counter for naming images
    counter=1

    # Create a temporary file to store image URLs for parallel download
    temp_file=$(mktemp)

    # Prepare image URLs with naming convention
    while IFS= read -r img_url; do
        [ -z "$img_url" ] && continue
        img_name="${repo_name}_${counter}.png"
        echo "$img_url ./$img_name" >> "$temp_file"
        counter=$((counter + 1))
    done <<< "$img_urls"

    # Use xargs to download images in parallel without showing curl output
    if [ -s "$temp_file" ]; then
        xargs -n 2 -P 8 sh -c 'curl -s -o "$1" "$0"' < "$temp_file"
    fi

    # Clean up temporary file
    rm -f "$temp_file"
}

# Main execution
if [ -n "$REPO_NAME" ]; then
    # Download for specific repository
    download_images "$REPO_NAME"
else
    # Get all repositories for the specified user with authentication
    GITHUB_API_URL="https://api.github.com/users/$USERNAME/repos?per_page=100"
    
    # Add authentication if available (recommended for higher rate limits)
    if [ -n "$GITHUB_TOKEN" ]; then
        auth_header="-H 'Authorization: token $GITHUB_TOKEN'"
    fi

    # Fetch repositories with error handling
    if ! repo_response=$(curl -s --fail $auth_header "$GITHUB_API_URL"); then
        echo -e "${C_RED}Failed to fetch repositories for $USERNAME${C_RESET}"
        exit 1
    fi

    # Extract repository names safely
    if ! repo_names=$(jq -r '.[].name' <<< "$repo_response"); then
        echo -e "${C_RED}Failed to parse repository names${C_RESET}"
        exit 1
    fi

    # Loop through each repository
    while IFS= read -r repo_name; do
        [ -z "$repo_name" ] && continue
        download_images "$repo_name"
    done <<< "$repo_names"
fi

echo -e "${C_GREEN}All images have been saved to current working directory: ${PWD} ${C_RESET}."
