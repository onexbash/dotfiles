# SHELL CONFIGURATION

## Helper Script

### Functions
#### detect_os()
```bash
# USAGE:
function some_function() {
    # 1) Define Function Blocks for each platform
    all() {
      # Commands that run on all platforms
    }
    linux(){
      # Commands that run on platform "linux"
      echo -e "${I_OK}Supported Platform Detected: $platform"
    }
    macos(){
      # Commands that run on platform "macos"
      echo -e "${I_OK}Supported Platform Detected: $platform"
    }
    unknown(){
      # Commands that run on platform "unknown"
      echo -e "${I_ERR}Unsupported Platform Detected: $platform"
      return
    }
    # 2) Get the value of `$platform` by calling `detect_os`
    local platform=$(detect_os)
    # 3) Call the detected platform function block
    all && $platform
}
some_function
```
