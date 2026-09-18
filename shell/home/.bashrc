# Source global bash config
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Function to load User BASH Config Files
load_configs() {
    local config_dir file path
    config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"

    # Define Config Files & Loading Order
    local configs=(
        "ssh.bash"
        "tools.bash"
        "aliases.bash"
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

