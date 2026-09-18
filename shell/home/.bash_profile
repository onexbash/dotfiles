# Source global bash_profile
if [ -f /etc/bash_profile ]; then
    . /etc/bash_profile
fi

# Function to load User BASH Config Files
load_configs() {
    local config_dir file path
    config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"

    # Define Config Files & Loading Order
    local configs=(
        "env.bash"
    )

    # Source defined Config Files
    for file in "${configs[@]}"; do
        path="$config_dir/${file}"
        if [ -r "$path" ]; then
            . "$path"
        else
            echo "ERR: Config file not found or unreadable: $path" >&2
        fi
    done
}
load_configs
