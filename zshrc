################# TERMINAL CONFIGS #######################

# Set default text editor
export EDITOR=vim

# Enable word splitting to match bash behavior
setopt SH_WORD_SPLIT

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Which plugins would you like to load?
plugins=(git asdf zsh-autosuggestions zsh-syntax-highlighting kubectl-autocomplete vi-mode)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# oh-my-zsh robbyrussel theme overrides
ZSH_THEME="robbyrussell"

PROMPT="%{$fg_bold[cyan]%}%T%{$fg_bold[green]%} %{$fg_bold[green]%}%7d%{$fg_bold[yellow]%}% %{$reset_color%}"
PROMPT+=' $(git_prompt_info)'
prompt_end() {    
  if [[ -n $CURRENT_BG ]]; then
      print -n "%{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
      print -n "%{%k%}"
  fi

  print -n "%{%f%}"
  CURRENT_BG=''

  #Adds the new line and ➜ as the start character.
  printf "\n ➜";
}
PROMPT+="$(prompt_end) "


################# AUTOCOMPLETES ######################

# aws-cli autocomplete
complete -C '/usr/local/bin/aws_completer' aws

# az-cli autocomplete
source /etc/bash_completion.d/azure-cli

# Terragrunt autocomplete
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terragrunt terragrunt

# Helm autocompletion
#compdef helm
compdef _helm helm

# zsh completion for helm                                 -*- shell-script -*-

__helm_debug()
{
    local file="$BASH_COMP_DEBUG_FILE"
    if [[ -n ${file} ]]; then
        echo "$*" >> "${file}"
    fi
}

_helm()
{
    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16
    local shellCompDirectiveKeepOrder=32

    local lastParam lastChar flagPrefix requestComp out directive comp lastComp noSpace keepOrder
    local -a completions

    __helm_debug "\n========= starting completion logic =========="
    __helm_debug "CURRENT: ${CURRENT}, words[*]: ${words[*]}"

    # The user could have moved the cursor backwards on the command-line.
    # We need to trigger completion from the $CURRENT location, so we need
    # to truncate the command-line ($words) up to the $CURRENT location.
    # (We cannot use $CURSOR as its value does not work when a command is an alias.)
    words=("${=words[1,CURRENT]}")
    __helm_debug "Truncated words[*]: ${words[*]},"

    lastParam=${words[-1]}
    lastChar=${lastParam[-1]}
    __helm_debug "lastParam: ${lastParam}, lastChar: ${lastChar}"

    # For zsh, when completing a flag with an = (e.g., helm -n=<TAB>)
    # completions must be prefixed with the flag
    setopt local_options BASH_REMATCH
    if [[ "${lastParam}" =~ '-.*=' ]]; then
        # We are dealing with a flag with an =
        flagPrefix="-P ${BASH_REMATCH}"
    fi

    # Prepare the command to obtain completions
    requestComp="${words[1]} __complete ${words[2,-1]}"
    if [ "${lastChar}" = "" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go completion code.
        __helm_debug "Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __helm_debug "About to call: eval ${requestComp}"

    # Use eval to handle any environment variables and such
    out=$(eval ${requestComp} 2>/dev/null)
    __helm_debug "completion output: ${out}"

    # Extract the directive integer following a : from the last line
    local lastLine
    while IFS='\n' read -r line; do
        lastLine=${line}
    done < <(printf "%s\n" "${out[@]}")
    __helm_debug "last line: ${lastLine}"

    if [ "${lastLine[1]}" = : ]; then
        directive=${lastLine[2,-1]}
        # Remove the directive including the : and the newline
        local suffix
        (( suffix=${#lastLine}+2))
        out=${out[1,-$suffix]}
    else
        # There is no directive specified.  Leave $out as is.
        __helm_debug "No directive found.  Setting do default"
        directive=0
    fi

    __helm_debug "directive: ${directive}"
    __helm_debug "completions: ${out}"
    __helm_debug "flagPrefix: ${flagPrefix}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        __helm_debug "Completion received error. Ignoring completions."
        return
    fi

    local activeHelpMarker="_activeHelp_ "
    local endIndex=${#activeHelpMarker}
    local startIndex=$((${#activeHelpMarker}+1))
    local hasActiveHelp=0
    while IFS='\n' read -r comp; do
        # Check if this is an activeHelp statement (i.e., prefixed with $activeHelpMarker)
        if [ "${comp[1,$endIndex]}" = "$activeHelpMarker" ];then
            __helm_debug "ActiveHelp found: $comp"
            comp="${comp[$startIndex,-1]}"
            if [ -n "$comp" ]; then
                compadd -x "${comp}"
                __helm_debug "ActiveHelp will need delimiter"
                hasActiveHelp=1
            fi

            continue
        fi

        if [ -n "$comp" ]; then
            # If requested, completions are returned with a description.
            # The description is preceded by a TAB character.
            # For zsh's _describe, we need to use a : instead of a TAB.
            # We first need to escape any : as part of the completion itself.
            comp=${comp//:/\\:}

            local tab="$(printf '\t')"
            comp=${comp//$tab/:}

            __helm_debug "Adding completion: ${comp}"
            completions+=${comp}
            lastComp=$comp
        fi
    done < <(printf "%s\n" "${out[@]}")

    # Add a delimiter after the activeHelp statements, but only if:
    # - there are completions following the activeHelp statements, or
    # - file completion will be performed (so there will be choices after the activeHelp)
    if [ $hasActiveHelp -eq 1 ]; then
        if [ ${#completions} -ne 0 ] || [ $((directive & shellCompDirectiveNoFileComp)) -eq 0 ]; then
            __helm_debug "Adding activeHelp delimiter"
            compadd -x "--"
            hasActiveHelp=0
        fi
    fi

    if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
        __helm_debug "Activating nospace."
        noSpace="-S ''"
    fi

    if [ $((directive & shellCompDirectiveKeepOrder)) -ne 0 ]; then
        __helm_debug "Activating keep order."
        keepOrder="-V"
    fi

    if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
        # File extension filtering
        local filteringCmd
        filteringCmd='_files'
        for filter in ${completions[@]}; do
            if [ ${filter[1]} != '*' ]; then
                # zsh requires a glob pattern to do file filtering
                filter="\*.$filter"
            fi
            filteringCmd+=" -g $filter"
        done
        filteringCmd+=" ${flagPrefix}"

        __helm_debug "File filtering command: $filteringCmd"
        _arguments '*:filename:'"$filteringCmd"
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subdir
        subdir="${completions[1]}"
        if [ -n "$subdir" ]; then
            __helm_debug "Listing directories in $subdir"
            pushd "${subdir}" >/dev/null 2>&1
        else
            __helm_debug "Listing directories in ."
        fi

        local result
        _arguments '*:dirname:_files -/'" ${flagPrefix}"
        result=$?
        if [ -n "$subdir" ]; then
            popd >/dev/null 2>&1
        fi
        return $result
    else
        __helm_debug "Calling _describe"
        if eval _describe $keepOrder "completions" completions $flagPrefix $noSpace; then
            __helm_debug "_describe found some completions"

            # Return the success of having called _describe
            return 0
        else
            __helm_debug "_describe did not find completions."
            __helm_debug "Checking if we should do file completion."
            if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
                __helm_debug "deactivating file completion"

                # We must return an error code here to let zsh know that there were no
                # completions found by _describe; this is what will trigger other
                # matching algorithms to attempt to find completions.
                # For example zsh can match letters in the middle of words.
                return 1
            else
                # Perform file completion
                __helm_debug "Activating file completion"

                # We must return the result of this command, so it must be the
                # last command, or else we must store its result to return it.
                _arguments '*:filename:_files'" ${flagPrefix}"
            fi
        fi
    fi
}

# don't run the completion function when being source-ed or eval-ed
if [ "$funcstack[1]" = "_helm" ]; then
    _helm
fi
compdef _helm helm


################# ALIASES ######################
# Kubernetes
alias kc="$(which kubectl) create"
alias k="$(which kubectl)"
alias kcc="$(which kubectl) config current-context"
alias ka="$(which kubectl) apply -f"
alias kdel="$(which kubectl) delete"
alias ksx="$(which kubectl) config set-context --current --namespace "
alias kux="$(which kubectl) config use-context "
alias kgx="$(which kubectl) config get-contexts"
alias kg="$(which kubectl) get"
alias kd="$(which kubectl) describe"
export dry="--dry-run=client -o yaml"
export now="--force --grace-period 0"

# Directories
alias pp="cd ~/cloud/studies/projects/"
alias ppc="cd ~/cloud/studies/projects/conquerproject"
alias tp="cd ~/cloud/jobs/trimble/projects/"
alias mc="cd ~/cloud/jobs/trimble/projects/ttm-platform-telematics"
alias mcg="cd ~/cloud/jobs/trimble/projects/ttm-platform-telematics/ttm-platform-gitops"

# General tools
alias cat="batcat -f"
alias less="batcat -f --paging=always"
eval "$(zoxide init zsh)"
alias cd="z"
alias xclip="xclip -sel clip"

# Scripts
alias ct="bash ~/cloud/studies/projects/bash-scripts/connection-tester/connection-tester.sh"
alias sup="bash ~/cloud/studies/projects/bash-scripts/system-updater/system_updater.sh -s"
alias fc="bash ~/cloud/studies/projects/bash-scripts/focus-chunker/focus-chunker.sh 40"
