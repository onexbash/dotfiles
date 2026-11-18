() {
  local prefix=${HOMEBREW_PREFIX:-/opt/homebrew}
  local -a kegs=(readline libxml2 libiconv openssl@3 icu4c@79 zlib sqlite krb5)
  local -a dirs=(
    $prefix/opt/${^kegs}/{lib,share}/pkgconfig(N/)   # existing keg dirs only
    ${(s/:/)PKG_CONFIG_PATH}                         # keep whatever was set before
  )
  export PKG_CONFIG_PATH=${(j/:/)${(u)dirs}}         # dedupe, join with ':'
}
