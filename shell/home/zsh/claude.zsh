# -- Claude-Code -- #
# Disable internal Claude Auto-Updater & handle via brew
function claude_set_env() {
  # variable set by user prompt when 'DISABLE_AUTOUPDATER' is set to 0
  local ignore_env_var && ignore_env_var="y"
  # Handle Cases of Environment Variable 'DISABLE_AUTOUPDATER'
  # is set to '1'
  if [[ $DISABLE_AUTOUPDATER -eq 1 ]]; then
    return 0 # exit function with success
  # is set to '0'
  elif [[ $DISABLE_AUTOUPDATER -eq 0 ]]; then
    echo -e "${I_WARN}The Environment Variable 'DISABLE_AUTOUPDATER' is set to [ ${FG_RED}$DISABLE_AUTOUPDATER${S_RESET} ] -> Claude Auto-Updater ${FG_RED}Enabled${S_RESET}."
    echo -e "${I_INFO}On MacOS this should be ${FG_GREEN}Disabled${S_RESET} & managed via Homebrew."
    echo -en "${I_ASK_YN}Ignore your Environment Variable & ${FG_GREEN}Disable${S_RESET} Claude Auto-Updater?" && read -r ignore_env_var
    if [[ "$ignore_env_var" == "n" || "$ignore_env_var" == "N" ]]; then
      echo -e "${I_WARN}Okay.. Idk why you would want that but you decide. Claude Auto-Updater will stay ${FG_RED}Enabled${S_RESET}."
      echo -e "${I_INFO}Exiting.." && return 0
    fi
  # is set to unsupported value
  else
    echo -e "${I_WARN}The Environment Variable 'DISABLE_AUTOUPDATER' is set to an unsupported value: [ ${FG_RED}$DISABLE_AUTOUPDATER${S_RESET} ]"
    echo -e "${I_INFO}Supported Values: [ ${FG_GREEN}1${S_RESET}/${FG_RED}0${S_RESET} ]"
    echo -e "${I_INFO}Falling back to default: ${FG_GREEN}1${S_RESET} -> Claude Auto-Updater ${FG_GREEN}Disabled${S_RESET}."
  fi
  
  # Ensure 'autoUpdates' is Disabled in Claude Config
  if claude config get -g autoUpdates | grep -q "true"; then
    echo -e "${I_INFO}Claude Auto-Updates are ${FG_RED}Enabled${S_RESET}. On MacOS this should be ${FG_GREEN}Disabled${S_RESET} & managed via Homebrew. Configuring.."
    claude config set -g autoUpdates false && echo -e "${I_OK}Claude Auto-Updater ${FG_GREEN}Disabled${S_RESET}" || echo -e "${I_ERR}Failed to disable Claude Auto-Updater" && return 0
  fi
}
claude_set_env

