# --            context.zsh            -- #
# --        sourced by: .zshrc         -- #
# --                                   -- #

# This File is used to load Context Specific Environment Configs, like Azure CLI Variables that differ between Tenants.
# Basically everything that has to be set per Environment.
# Configs: ~/.config/env
#
# Shell startup:  loads the tenant from $AZ_TENANT  (default: cratos-dev).
# Switch later :  env_azure cratos-prod             (argument wins over $AZ_TENANT)


# -- Main Function -- #
function main() {
  local env_dir="${XENV:-${XDG_CONFIG_HOME:-$HOME/.config}/env}"
  env_azure "$@"                 # env_azure sees env_dir
}

# -- Azure -- #
# Configs: ~/.config/env/azure/<tenant>.env

# Load Azure Environment Variables
# Usage: env_azure [cratos-dev|cratos-prod|eon-dev|..]
function env_azure() {
  local dir="${env_dir:-${XENV:-${XDG_CONFIG_HOME:-$HOME/.config}/env}}/azure" # env_dir inherited from main()
  local tenant="${1:-${AZ_TENANT:-cratos-dev}}"
  local file="$dir/$tenant.env"

  case "$tenant" in
    cratos-dev|cratos-prod|eon-dev) ;;
    *) log_warn "env_azure: unknown tenant '$tenant' (cratos-dev, cratos-prod, eon-dev)" >&2; return 1 ;;
  esac
  [[ -r "$file" ]] || { log_err "env_azure: $file not found" >&2; return 1; }

  # Clear values from the previous tenant, then load the new ones
  unset AZ_DEVOPS_ORG AZ_DEVOPS_PROJECT AZ_DEVOPS_REPO \
        AZ_TENANT_ID AZ_SUBSCRIPTION_ID AZ_CLIENT_ID AZ_CLIENT_SECRET
  set -a; source "$file"; set +a
  export AZ_TENANT="$tenant"
  log_info "Azure tenant: $AZ_TENANT (org: ${AZ_DEVOPS_ORG:-none}, config: $file)"
}


# Call Main Function (shell startup)
main >/dev/null
