#!/bin/bash

# Since I have 2 computers running Ubuntu 23.10 and I'm having a hard time keeping their configs synced, \
# I created this script to do that for me.

set -eo pipefail

# Display how to use this script
usage() {
    echo "Usage: $0 --full  # Install or update everything"
    echo "usage: $0 --diff  # Install not installed packages" 
    exit 1
}

# Get script option from the user
get_opt() {
    if [ "$#" -eq 1 ]; then
        case $1 in
            --full)
                user_opt="--full";;
            --diff)
                user_opt="--diff";;
            *)
                usage;;
        esac
    else
        usage
    fi
}

########## General System Preferences ###############
dont_ask_sudo_pass() {
    echo "%$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/"$USER" > /dev/null
    echo "$USER added to sudoers file"
}

########## Add APT Repositories ###########
add_apt_repos() {
    # Terraform
    if [[ -z "$(apt list --installed 2>/dev/null | grep 'terraform.*installed')" || "$1" == "--full" ]]; then
        curl -sL -o gpg https://apt.releases.hashicorp.com/gpg 
        gpg --dearmor gpg && sudo mv -f gpg.gpg /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
            https://apt.releases.hashicorp.com jammy main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
        rm gpg
    fi

    # vscode
    if [[ -z "$(apt list --installed 2>/dev/null | grep "^code.*installed")" || "$1" == "--full" ]]; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg
    fi
    
    # Github CLI
    if [[ -z "$(apt list --installed 2>/dev/null | grep "^gh/.*installed")" || "$1" == "--full" ]]; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    fi
}


########## Install APT Packages ##########
install_apt_apps() {
    apt_apps=(vim-gtk3 tree git zsh bash-completion flameshot tilix jq yq \
              wget gpg curl gnupg software-properties-common terraform apt-transport-https \
              code xdotool chrome-gnome-shell gnome-browser-connector xclip gh shellcheck ansible)
    echo "### APT Packages ###"
    sudo apt update -y > /dev/null 2>&1
    sudo apt install -y "${apt_apps[@]}" > /dev/null 2>&1
    echo "Installed Packages: ${apt_apps[@]}"
}

########## Non-package manager Installations ##########
install_non-apt_apps() {
    echo -e "\n### Non-APT Packages ###"
    # Google Chrome
    if [[ -z "$(dpkg -l | grep google-chrome)" || "$1" == "--full" ]]; then
        curl -sL -o /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo dpkg -i /tmp/chrome.deb > /dev/null
        echo "Chrome Installed"
    else
        echo "Chrome already installed"
    fi

    # Oh My Zsh
    if [[ ! -d ~/.oh-my-zsh || "$1" == "--full" ]]; then
        if [ -d ~/.oh-my-zsh ]; then
            rm -rf ~/.oh-my-zsh
        fi
        curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o install.sh
        sed -i '/exec\ zsh\ -l/d' install.sh
        bash install.sh > /dev/null 2>&1
        echo "Oh My Zsh installed"
        rm install.sh
    else
        echo "oh-my-zsh already installed"
    fi

    # asdf
    if [[ ! -d ~/.asdf || "$1" == "--full" ]]; then
        asdf_latest_version="$(git ls-remote --tags --sort=v:refname https://github.com/asdf-vm/asdf.git | awk -F"/" '{print $3}'| tail -1)"
        if [ -d ~/.asdf ]; then
            rm -rf ~/.asdf
        fi
        git clone -q https://github.com/asdf-vm/asdf.git ~/.asdf --branch "$asdf_latest_version" > /dev/null 2>&1
        echo "asdf Installed"
        
    else
        echo "asdf already installed"

    fi

    # mega
    if [[ -z "$(apt list --installed 2>/dev/null | grep 'mega.*installed')" || "$1" == "--full" ]]; then
        curl -sL -o /tmp/mega.deb https://mega.nz/linux/repo/xUbuntu_23.10/amd64/megasync-xUbuntu_23.10_amd64.deb
        sudo apt install /tmp/mega.deb > /dev/null 2>&1
        echo "Mega Installed"
    else
        echo "Mega already installed"
    fi

    # kubectl
    if [[ ! -f /usr/local/bin/kubectl || "$1" == "--full" ]]; then
        curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        echo "Kubectl Installed"
        rm -f kubectl
    else 
        echo "kubectl already installed"
    fi

    # docker
    if [[ -z "$(dpkg -l | grep docker)" || "$1" == "--full" ]]; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sed -i 's/sleep\ 20/sleep\ 1/' get-docker.sh
        sudo sh get-docker.sh > /dev/null 2>&1
        sudo usermod -aG docker $USER
        echo "Docker Installed"
        rm -f get-docker.sh
    else
        echo "Docker already installed"
    fi
    
    # Discord
    if [[ -z "$(apt list --installed 2>/dev/null | grep "^discord.*installed")" || "$1" == "--full" ]]; then
        wget -q "https://discord.com/api/download?platform=linux&format=deb" -O discord.deb
        sudo apt install ./discord.deb > /dev/null 2>&1
        echo "Discord Installed"
        rm -f discord.deb
    else
        echo "Discord already installed"
    fi

    # AWS-CLI
    if [[ ! -f /usr/local/bin/aws || "$1" == "--full" ]]; then
        curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip > /dev/null
        if [ -d /usr/local/aws-cli/v2/current ]; then
            sudo ./aws/install --update > /dev/null
            echo "AWS CLI Updated"
        else
            sudo ./aws/install > /dev/null
            echo "AWS CLI Installed"
        fi
        rm -f awscliv2.zip
        rm -rf ./aws
    else
        echo "aws-cli already installed"
    fi
    
    # AZURE-CLI
    if [[ -z "$(dpkg -l | grep azure-cli)" || "$1" == "--full" ]]; then
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash > /dev/null
        sudo az aks install-cli > /dev/null 2>&1
        echo "az-cli Installed and kubelogin installed"
    else
        echo "az-cli already installed"
        if [[ ! $(which kubelogin)  ]]; then
            az aks install-cli
            echo "kubelogin installed"
        else
            echo "kubelogin already installed"
        fi
    fi

    # Terragrunt
    if [[ ! -f /usr/local/bin/terragrunt || "$1" == "--full" ]]; then
        terragrunt_latest_version="$(git ls-remote --tags --sort=v:refname https://github.com/gruntwork-io/terragrunt.git | awk -F"/" '{print $3}'| tail -1)"
        curl -sL -o /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/$terragrunt_latest_version/terragrunt_linux_amd64
        echo "terragrunt installed"
    else
        echo "terragrunt already installed"
    fi    

    # Terraform-docs
    if [[ ! -f /usr/local/bin/terraform-docs || "$1" == "--full" ]]; then
        curl -sLo /tmp/terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.17.0/terraform-docs-v0.17.0-$(uname)-amd64.tar.gz
        tar -xzf /tmp/terraform-docs.tar.gz -C /tmp
        chmod +x /tmp/terraform-docs
        sudo mv /tmp/terraform-docs /usr/local/bin/terraform-docs
        echo "Terraform-docs installed"
    else
        echo "terraform-docs already installed"
    fi
}

########## Configure Applications ###########
config_apps() {
    echo -e "\n### Apply Apps configs ###"
    # Tilix as default
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/tilix 100
    sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix

    # Tilix appearance
    tilix_profile="default"
    dconf write /com/gexperts/Tilix/profiles/"$tilix_profile"/background-transparency-percent "20"
    dconf write /com/gexperts/Tilix/profiles/"$tilix_profile"/default-size-columns "120"
    dconf write /com/gexperts/Tilix/profiles/"$tilix_profile"/default-size-rows "35"

    # Tilix shortcuts
    dconf write /com/gexperts/Tilix/keybindings/session-close "'<Ctrl><Alt>w'"
    dconf write /com/gexperts/Tilix/unsafe-paste-alert false
    dconf write /com/gexperts/Tilix/use-tabs true
    for i in {1..9}; do
        dconf write /com/gexperts/Tilix/keybindings/win-switch-to-session-$i "'<Ctrl>$i'"
    done
    dconf write /com/gexperts/Tilix/keybindings/win-switch-to-previous-session "'<Ctrl><Shift>Tab'"
    dconf write /com/gexperts/Tilix/keybindings/win-switch-to-next-session "'<Ctrl>Tab'"
    dconf write /com/gexperts/Tilix/keybindings/terminal-close "'<Ctrl><Shift>w'"
    dconf write /com/gexperts/Tilix/keybindings/terminal-page-down "'Page_Down'"
    dconf write /com/gexperts/Tilix/keybindings/terminal-page-up "'Page_Up'"
    dconf write /com/gexperts/Tilix/keybindings/terminal-zoom-out "'<Ctrl>underscore'"
    echo "Tilix Configured"

    # vim
    cat "$PWD"/vimrc > ~/.vimrc
	if [ ! -d ~/.vim/pack/plugins/start/vim-terraform ]; then
		git clone https://github.com/hashivim/vim-terraform.git ~/.vim/pack/plugins/start/vim-terraform
		echo "vim-terraform installed"
    elif [[ -d ~/.vim/pack/plugins/start/vim-terraform && "$1" == "--full" ]]; then
		rm -rf ~/.vim/pack/plugins/start/vim-terraform
		git clone https://github.com/hashivim/vim-terraform.git ~/.vim/pack/plugins/start/vim-terraform
		echo "vim-terraform updated"
	else
		echo "vim-terraform already installed"
	fi
	echo "Vim configured"

    # ZSH
    if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
        git clone -q https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        echo "zsh-autosuggestions Installed"
    elif [[ -d ~/.oh-my-zsh/plugins/zsh-autosuggestions && "$1" == "--full" ]]; then
        rm -rf ~/.oh-my-zsh/plugins/zsh-autosuggestions
        git clone -q https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        echo "zsh-autosuggestions Updated"
    else
        echo "zsh-autosuggestions already installed"
    fi
    
	if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
        git clone -q https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        echo "zsh-syntax-highlighting Installed"
    elif [[ -d ~/.oh-my-zsh/plugins/zsh-syntax-highlighting && "$1" == "--full" ]]; then
        rm -rf ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
        git clone -q https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        echo "zsh-syntax-highlighting Updated"
    else
        echo "zsh-syntax-highlighting already installed"
    fi   
	
    if [ ! -d ~/.oh-my-zsh/custom/plugins/kubectl-autocomplete ]; then
        mkdir -p ~/.oh-my-zsh/custom/plugins/kubectl-autocomplete
        kubectl completion zsh > ~/.oh-my-zsh/custom/plugins/kubectl-autocomplete/kubectl-autocomplete.plugin.zsh
        echo "kubectl-autocomplete installed"
    elif [[ -d ~/.oh-my-zsh/custom/plugins/kubectl-autocomplete && "$1" == "--full" ]]; then
        rm -rf ~/.oh-my-zsh/custom/plugins/kubectl-autocomplete
        mkdir -p ~/.oh-my-zsh/custom/plugins/kubectl-autocomplete
        kubectl completion zsh > ~/.oh-my-zsh/custom/plugins/kubectl-autocomplete/kubectl-autocomplete.plugin.zsh
        echo "kubectl-autocomplete Updated"
    else
        echo "kubectl-autocomplete already installed"
    fi   
    
    cat "$PWD"/zshrc > ~/.zshrc
    echo "Zsh configured"

    # MiniKube
    if [[ ! "$(which minikube)" || "$1" == "--full" ]]; then
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
    else
        echo "Minikube already installed"
    fi

    # Helm
    if [[ ! "$(which helm)" || "$1" == "--full" ]]; then
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        helm completion zsh > "${fpath[1]}/_helm"
    else
        echo "helm already installed"
    fi
}

########## Gnome Settings ##########
gnome_settings() {
    echo -e "\n### Gnome Preferences ###"
    # Ubuntu Dock
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 20

    # Keyboard layout - Logitech K380
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us+alt-intl'), ('xkb', 'br')]"

    # Show battery percentage
    gsettings set org.gnome.desktop.interface show-battery-percentage true

    # Remove trash from dock
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false

    # Manage Windows & Workspaces
    gsettings set org.gnome.shell.app-switcher current-workspace-only true
    gsettings set org.gnome.shell.extensions.dash-to-dock isolate-monitors true
    gsettings set org.gnome.mutter dynamic-workspaces false
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 3

    # Custom shortcuts
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/']" 
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'bluetooth settings'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-control-center bluetooth'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Ctrl><Alt>b'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'flameshot'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'sh -c -- "flameshot gui"'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding 'Print'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'Mute Mic'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'bash -c "amixer set Capture toggle"'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Ctrl><Alt>m'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ name 'Put Focus Next Monitor'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ command "bash $PWD/swap-screens.sh"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ binding '<Super>Tab'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ name 'Sound Settings'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ command 'gnome-control-center sound'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ binding '<Ctrl><Alt>s'
    
    # Change default Shortcuts
    gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"   
    gsettings set org.gnome.shell.keybindings show-screenshot-ui "[]"

    # Disable Desktop Icons NG (DING) extension
    gnome-extensions disable ding@rastersoft.com    

    echo "Gnome preferences applied"
}

gnome_extensions() {
    echo -e "\n### Gnome Extensions ###"

    local install_extensions=(
        "https://extensions.gnome.org/extension-data/clipboard-historyalexsaveau.dev.v40.shell-extension.zip"
        "https://extensions.gnome.org/extension-data/NotificationCountercoolllsk.v8.shell-extension.zip"
    )

    for extension in "${install_extensions[@]}"; do
        wget -qO "extension.zip" "$extension" 
        gnome-extensions install --force "extension.zip" > /dev/null
        rm "extension.zip"
    done

    local user_extensions=($(gnome-extensions list --user))
    for extension in "${user_extensions[@]}"; do
        gnome-extensions enable "$extension"
        echo "$extension installed"
    done
}


main() {
    get_opt "$@"
    dont_ask_sudo_pass
    add_apt_repos "$1"
    install_apt_apps
    install_non-apt_apps "$1"
    config_apps
    gnome_settings
    gnome_extensions
    echo -e "\n##### Finished! ######"
}

main "$@"

