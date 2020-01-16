#!/usr/bin/env bash

###############################################################################
# Summary: Makes sure aws_adfs_auth is locally installed. Installs it if not.
# Required Positional Argument: n/a
# Returns: n/a
###############################################################################
assert_aws_adfs_auth()
{
    if ! command -v aws_adfs_auth > /dev/null; then
        echo "Installing aws_adfs_auth"
        if command -v wget > /dev/null; then
            wget -O /usr/local/bin/aws_adfs_auth "http://yumrepo.sys.comcast.net/onecloud/aws_adfs_auth/v0.0.20/aws_adfs_auth_linux_amd64"
        else 
            curl -o /usr/local/bin/aws_adfs_auth "http://yumrepo.sys.comcast.net/onecloud/aws_adfs_auth/v0.0.20/aws_adfs_auth_linux_amd64"
        fi
        chmod +x /usr/local/bin/aws_adfs_auth
        assert_in_path "/usr/local/aws_adfs_auth"
    fi
    if ! command -v aws_adfs_auth > /dev/null; then
        echo "Installing aws_adfs_auth failed. aws_adfs_auth is necessary please download the necessary version from GitHub releases https://github.com/concourse/concourse/releases"
        exit 1
    fi
}

###############################################################################
# Summary: Makes sure brew is locally installed. Installs it if not.
# Required Positional Argument: n/a
# Returns: n/a
###############################################################################
assert_brew()
{
    if ! command -v brew; then
        echo " Installing brew..."
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    if ! command -v brew > /dev/null; then
        echo "Installing brew failed. brew is necessary please install brew manuall. See https://brew.sh/"
        exit 1
    fi
}

###############################################################################
# Summary: Makes sure envsubst is locally installed. Installs it if not.
# Required Positional Argument: n/a
# Returns: n/a
###############################################################################
assert_envsubst()
{
    if ! command -v envsubst > /dev/null; then
        echo "Installing envsubst"
        if command -v apk; then
            apk add gettext
        elif command -v apt-get; then
            apt-get install gettext-base
        else
            assert_brew
            brew install gettext
            ln -s /usr/local/opt/gettext/bin/envsubst /usr/local/bin/envsubst
        fi
    fi
    if ! command -v envsubst > /dev/null; then
        echo "Installing envsubst failed. envsubst is necessary please download the necessary version see https://command-not-found.com/envsubst"
        exit 1
    fi
}

###############################################################################
# Summary: Asserts the specified argument points to a readable file. 
# Required Positional Argument: 
#   $file_path - The name of the argument containing a file path.
# Returns: Prints error and exits if not a readable file. 
###############################################################################
assert_file_arg()
{
    required_file_path=$(get_value_of "$1")
    [ -z "$required_file_path" ] && required_file_path="$1"
    if [ ! -r "${required_file_path}" ]; then 
        printf "'%s' must be a readable file.\\n" "$1"
        exit 1
    fi
}

###############################################################################
# Summary: Makes sure fly is locally installed. Installs it if not.
# Required Positional Argument: n/a
# Returns: n/a
###############################################################################
assert_fly()
{
    if ! command -v fly > /dev/null; then
        echo "Installing fly"
        if command -v wget > /dev/null; then
            wget -O /usr/local/bin/fly "https://ci.comcast.net/api/v1/cli?arch=amd64&platform=darwin"
        else 
            curl -o /usr/local/bin/fly "https://ci.comcast.net/api/v1/cli?arch=amd64&platform=darwin"
        fi
        chmod +x /usr/local/bin/fly
        assert_in_path "/usr/local/bin"
    fi
    if ! command -v fly > /dev/null; then
        echo "Installing fly failed. fly is necessary please download the necessary version from GitHub releases https://github.com/concourse/concourse/releases"
        exit 1
    fi
}

###############################################################################
# Summary: Makes sure the passed in directory is in the PATH envvar.
# Required Positional Argument: 
#   dirtoadd - The directory to add to the PATH envvar.
# Returns: n/a
# Sample Usage: 
#   assert_in_path "/usr/local/bin"
###############################################################################
assert_in_path()
{
    dirtoadd="$dirtoadd"
    [ ! -d "$dirtoadd" ] && return 1
    if ! echo "$PATH" | tr ":" "\\n" | grep -qE "^/usr/local/bin/?$"; then
        echo "PATH=\"$dirtoadd:\$PATH\"" >> "$HOME/.bash_profile"
        # shellcheck disable=SC1090
        source "$HOME/.bash_profile"
        echo " Added '$dirtoadd' to PATH."
    fi
}

###############################################################################
# Summary: Makes sure md5sum is locally installed. Installs it if not.
# Required Positional Argument: n/a
# Returns: n/a
###############################################################################
assert_md5sum()
{
    command_to_assert="md5sum"
    if ! command -v $command_to_assert > /dev/null; then
        echo "Installing dependency: $command_to_assert"
        if command -v md5; then 
            md5sum() {
                md5 "$@"
            }
            echo "$command_to_assert installed"
        fi
        ! command -v $command_to_assert > /dev/null && echo "Installing $command_to_assert failed. $command_to_assert is a necessary dependency." && exit 1
    fi
    return 0
}

###############################################################################
# Summary: Makes sure readarray command will function.
# Required Positional Argument: n/a
# Returns: Absolute path to the ci folder
###############################################################################
assert_readarray()
{
    if ! help readarray &> /dev/null; then 
        # shellcheck disable=SC1090
        . "$(get_ci_root)/concourse/common/scripts/polyfills/readarray.sh"
    fi
}

###############################################################################
# Summary: Asserts the specified "argument" (i.e. variable) is set. 
# Required Positional Argument: 
#   $arg_name - The name of the argument to assert is set
# Returns: Prints error and exits if not set. 
###############################################################################
assert_required_arg()
{
    required_value=$(get_value_of "$1")
    if [ "${required_value}" = "" ]; then 
        printf "[ERROR] %s is a required argument.\\n" "$1"
        exit 1
    fi
}

###############################################################################
# Summary: Makes sure unzip is locally installed. Installs it if not.
# Required Positional Argument: n/a
# Returns: n/a
###############################################################################
assert_unzip()
{
    if ! command -v unzip > /dev/null; then
        echo "Installing dependency: unzip"
        command -v apk && apk --update add unzip && return
        command -v apt-get && apt-get update && apt-get install unzip && return
        assert_brew
        brew install unzip
        if ! command -v unzip > /dev/null; then
            echo "Installing unzip failed. unzip is a necessary dependency."
            exit 1
        fi
    fi
}


###############################################################################
# Summary: Makes sure uuidgen is locally installed. Installs it if not.
# Required Positional Argument: n/a
# Returns: n/a
###############################################################################
assert_uuidgen()
{
    if ! command -v uuidgen > /dev/null; then
        echo "Installing dependency: uuidgen"
        command -v apk && apk --update add util-linux && return
        command -v apt-get && apt-get update && apt-get install uuid-runtime && return
        if ! command -v uuidgen > /dev/null; then
            echo "Installing uuidgen failed. uuidgen is a necessary dependency."
            exit 1
        fi
    fi
}

###############################################################################
# Summary: Makes sure yq is locally installed. Installs it if not.
# Required Positional Argument: n/a
# Returns: n/a
###############################################################################
assert_yq()
{
    if ! command -v yq > /dev/null; then
        echo "Installing dependency: yq"
        assert_brew
        brew install yq
    fi
    if ! command -v yq > /dev/null; then
        echo "Installing yq failed. YQ is necessary please find installation instructions at https://github.com/mikefarah/yq"
        exit 1
    fi
}

###############################################################################
# Summary: Returns the absolute path to the ci root folder.
# Required Positional Argument: n/a
# Returns: Absolute path to the ci folder
###############################################################################
get_ci_root()
{
    [ -d "concourse" ] && pwd && return
    [ -d "ci-common" ] && echo "$(pwd)/ci-common" && return
    [ -d "source-code/concourse" ] && echo "$(pwd)/source-code" && return
    [ -d "/concourse" ] && echo "/concourse" && return
    echo "ci root directory not found!" >&2
    exit 1
}

###############################################################################
# Summary: Returns the value of a variable given it's name as a string.
# Required Positional Argument: 
#   variable_name - The name of the variable to return the value of
# Returns: The value if variable exists; otherwise, empty string ("").
###############################################################################
get_value_from_file()
{
    if [ ! -r "$1" ]; then
        exit 1; 
    fi
    cat "$1"
}

###############################################################################
# Summary: Returns the value of a variable given it's name as a string.
# Required Positional Argument: 
#   variable_name - The name of the variable to return the value of
# Returns: The value if variable exists; otherwise, empty string ("").
###############################################################################
get_value_of()
{
    variable_value=""
    # zsh 
    # variable_value=${(P)1}
    # bash
    # variable_value=${!1}
    # sh -- you need to check set first, only then eval 
    if set | grep -q "^$1="; then
        eval variable_value="\$$1"
    fi
    echo "$variable_value"
}

###############################################################################
# Summary: Checks if the passed text represents a truthy value
# Required Positional Argument: 
#   text - the text that may be truthy
# Returns: 0 exit code for true 
###############################################################################
isTrue()
{
    text="$1"
    echo "$text" | grep -iE "^(yes|y|true|t|1)$"
}

###############################################################################
# Summary: Prompts the user for a value.
# Required Positional Argument: 
#   promttext - What are you asking the user for
# Returns: the entered text. 
###############################################################################
propmt()
{
    prompttext=$1
    read -rp "$prompttext" promptvalue
    echo "$promptvalue"
}

###############################################################################
# Summary: Prompts the user for a value.
# Required Positional Argument: 
#   promttext - What are you asking the user for
# Returns: the entered text. 
###############################################################################
propmt_required()
{
    prompttext=$1
    while [ -z "$promptvalue" ]; do
        promptvalue=$(propmt "$prompttext")
        [ -z "$promptvalue" ] && promptvalue=
    done
    echo "$promptvalue"
}

###############################################################################
# Summary: Prompts the user for a value must be contained in one of the args.
# Required Positional Argument: 
#   varname - What are you asking the user for
# Returns: the entered text. 
###############################################################################
propmt_options()
{
    varname="$1"
    prompttext="Please specify $varname from one of the following:"
    shift
    valid_options=
    while [ -n "$1" ]; do 
        [ "$valid_options" ] && \
            valid_options="$(printf "%s\\n%s" "$valid_options" "$1")" && \
            shift && \
            continue
        valid_options="$1" && shift
    done
    # remove any empty lines
    valid_options="$(echo "$valid_options" | sed -E 's/^$//')"
    declare -i index=0
    
    while IFS= read -r option; do 
        index=$((index+1))
        prompttext="$prompttext$(printf "\\n ")$index) $option"
    done <<<"$valid_options"

    prompttext="$prompttext$(printf "\\n[")$varname]: "
    promptvalue=
    while [ -z "$promptvalue" ]; do
        promptvalue=$(propmt_required "$prompttext")
        if [[ "$promptvalue" =~ ^[0-9]+$ ]]; then
            { (( promptvalue > index )) \
            || (( promptvalue < 1 )); } && promptvalue="" && continue
            promptvalue=$(echo "$valid_options" | sed "${promptvalue}q;d")
        else
            ! grep -q -E "^$promptvalue\$" <<<"$valid_options" && promptvalue="" && continue
        fi        
    done
    echo "$promptvalue"
}

###############################################################################
# Summary: Prompts the user for a value, returns default if nothing entered
# Required Positional Argument: 
#   promttext - What are you asking the user for
#   default - The default value to return when user hits enter with no value. 
# Returns: the entered text or the default value. 
###############################################################################
propmt_with_default()
{
    promptvalue=$(propmt "$1 ($2): ")
    [ -z "$promptvalue" ] && promptvalue="$2"
    echo "$promptvalue"
}

###############################################################################
# Summary: Prompts the user for a boolean value. Asks until boolean value given
# Required Positional Argument: 
#   promttext - What you are asking the user for
# Returns: the entered text. 
###############################################################################
prompt_bool()
{
    prompttext="$1 [yes/no]: "
    while [ -z "$promptvalue" ]; do
        promptvalue="$(propmt "$prompttext" | grep -iE "^(yes|y|true|t|1|no|n|false|f|0)$")"
    done
    isTrue "$promptvalue" && promptvalue=
}

###############################################################################
# Summary: Wrapper to the replace_pattern.awk script
# Required Positional Argument: 
#   pattern  - What is the pattern of the text you are replacing
#   template - The file or stdin ( - ) of the content to find pattern in
#   replacement text  - The file or stdin ( - ) of the text to replace the 
#                       pattern with. 
# Returns: the text with replacement.  
# Sample Usage: 
#   replace_pattern "^Hello" "path/to/template.file" "path/to/replacement.file"
#   replace_pattern "^Hello" <(echo "Hello") <(echo "Hello world!")
###############################################################################
replace_pattern()
{
    PATTERN="$1" "$(get_ci_root)/concourse/common/scripts/replace_pattern.awk" "$3" "$2"
}

###############################################################################
# setup_aws_auth
# Requires: 
#   aws_access_key  - The AWS IAM User Access Key
#   aws_secret_key  - The AWS IAM User Access Secret
#   aws_region      - The AWS Region, defaults to us-east-1
###############################################################################
setup_aws_auth()
{
    ex="$(grep -o "x" <<< "$-")" && set +x

    aws_access_key="${1:-$aws_access_key}"
    aws_secret_key="${2:-$aws_secret_key}"
    aws_region="${3:-$aws_region}"

    # Make sure all required ENV VARS are set.
    assert_required_arg aws_access_key
    assert_required_arg aws_secret_key

    # Configure AWS
    AWS_ACCESS_KEY_ID="$aws_access_key"
    AWS_SECRET_ACCESS_KEY="$aws_secret_key"
    AWS_DEFAULT_REGION="${aws_region:-"us-east-1"}"
    export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION

    [ "$ex" ] && set -x
}

###############################################################################
# Summary: Sources variables from environment vars that start with a prefix. 
#   generally used before running envsubst
# Required Positional Argument: n/a
# Optional Positional Argument: 
#   envvarprefix - What prefix should be used when looking for env vars to 
#                  source. Defaults to '__' (two (2) underscores)
# Returns: n/a
# Sample Usage: 
#   source_env_vars "__"
#   source_env_vars
###############################################################################
source_env_vars()
{
    prefixpattern="^${1:-"__"}"
    # Get properties from environment variables that start with __
    paramsToSource="$(printenv |
        awk -v prefix="$prefixpattern" -F"#;#." '$0 ~ prefix {sub(prefix,"");sub(/=/,"#;#.");printf "export %s=\"$([[ -r \"%s\" ]] && cat \"%s\" || echo \"%s\")\"\n",$1,$2,$2,$2 }')"
    source /dev/stdin <<<"$paramsToSource"
}