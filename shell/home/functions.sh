#!/usr/bin/env zsh

# Github Banner Generator
function bannergen() {
  THIS_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
  
  "$THIS_DIR/scripts/github_banner_generator.sh" || echo -e "${I_ERR} File doesn't exist: $THIS_DIR/scripts/github_banner_generator.sh"
}
