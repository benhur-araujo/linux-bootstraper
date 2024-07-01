################# TERMINAL CONFIGS #######################

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Which plugins would you like to load?
plugins=(git asdf zsh-autosuggestions zsh-syntax-highlighting kubectl-autocomplete)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# oh-my-zsh robbyrussel theme overrides
ZSH_THEME="robbyrussell"

PROMPT="%{$fg_bold[cyan]%}%T%{$fg_bold[green]%} %{$fg_bold[green]%}%3d%{$fg_bold[yellow]%}% %{$reset_color%}"
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


################# ALIASES ######################

# k8s
alias k="$(which kubectl)"
alias kcs="$(which kubectl) config set-context --current --namespace "
alias kcu="$(which kubectl) config use-context "
alias kcg="$(which kubectl) config get-contexts"

# directories
alias pp="cd ~/cloud/studies/projects/"
alias ppc="cd ~/cloud/studies/projects/conquerproject"
alias tp="cd ~/cloud/jobs/trimble/projects/"
alias tgp="cd ~/cloud/jobs/trimble/projects/ttm-platform-telematics"

# general tools
alias cat="batcat -f"
alias less="batcat -f --paging=always"
eval "$(zoxide init zsh)"
alias cd="z"
alias xclip="xclip -sel clip"
