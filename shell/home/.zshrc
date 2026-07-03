for file in "${XDG_CONFIG_HOME}/shell"/*.zsh(N); do
  source "$file"
done
