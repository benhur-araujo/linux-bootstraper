#!/bin/bash

# Since I have 2 computers running Ubuntu 23.10 and I'm having a hard time keeping their configs synced, \
# I created this script to do that for me.

########## Add APT Repositories ###########
add_apt_repos() {
    # Terraform
    if [ -z "$(apt list --installed | grep 'terraform.*installed')" ]; then
        wget -O- https://apt.releases.hashicorp.com/gpg | \
            gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
            https://apt.releases.hashicorp.com jammy main" | \
            sudo tee /etc/apt/sources.list.d/hashicorp.list
    fi

    # vscode
    if [ -z "$(apt list --installed | grep "^code.*installed")" ]; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg
    fi
}

########## Install APT Packages ##########
install_apt_apps() {
    sudo apt update -y && \
        sudo apt install -y vim-gtk3 tree git zsh bash-completion flameshot tilix jq yq \
        wget gpg curl gnupg software-properties-common terraform apt-transport-https code xdotool
}

########## Non-package manager Installations ##########
install_non-apt_apps() {
    # Google Chrome
    if [ -z "$(dpkg -l | grep google-chrome)" ]; then
        curl -o /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo dpkg -i /tmp/chrome.deb
        echo "Chrome Installed"
    fi

    # Oh My Zsh
    if [ ! -d ~/.oh-my-zsh ]; then
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        echo "Oh My Zsh installed"
    fi

    # asdf
    if [ ! -d ~/.asdf ]; then
        asdf_latest_version="$(git ls-remote --tags --sort=v:refname https://github.com/asdf-vm/asdf.git | awk -F"/" '{print $3}'| tail -1)"
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch "$asdf_latest_version"
        echo "asdf Installed"
        
        if [ -z "$(grep "plugins=(.*asdf.*)" ~/.zshrc)" ]; then
                plugins="$(grep "^plugins=(.*.)" ~/.zshrc | sed 's/)$//')"
                plugins="$plugins asdf)"
                sed -i "s/^plugins=.*/$plugins/" ~/.zshrc
        fi  
    fi

    # mega
    if [ -z "$(apt list --installed | grep 'mega.*installed')" ]; then
        curl -o /tmp/mega.deb https://mega.nz/linux/repo/xUbuntu_23.10/amd64/megasync-xUbuntu_23.10_amd64.deb
        sudo apt install /tmp/mega.deb
    fi
}

########## Configure Applications ###########
config_apps() {
    # Tilix as default
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/tilix 100
    sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix

    # Tilix appearance
    tilix_profile="($dconf list /com/gexperts/Tilix/profiles/ | head -1 | tr -d /)"
    dconf write /com/gexperts/Tilix/profiles/"$tilix_profile"/background-transparency-percent "6"
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
    dconf write /com/gexperts/Tilix/keybindings/win-switch-to-next-session "'<Ctrl><Tab'"
    dconf write /com/gexperts/Tilix/keybindings/terminal-close "'<Ctrl><Shift>w'"
    # vim
    cat ./vimrc  > ~/.vimrc

    # ZSH
    #if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    #    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    #    if [ -z $(grep "plugins=(.*zsh-autosuggestions.*)" ~/.zshrc) ]; then
    #        plugins="$(grep "^plugins=(.*.)" ~/.zshrc | sed 's/)$//')"
    #        plugins="$plugins zsh-autosuggestions)"
    #        sed -i "s/^plugins=.*/$plugins/" ~/.zshrc
    #    fi
    #fi
    #
    #if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    #        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    #     if [ -z $(grep "plugins=(.*zsh-syntax-highlighting.*)" ~/.zshrc) ]; then
    #            plugins="$(grep "^plugins=(.*.)" ~/.zshrc | sed 's/)$//')"
    #            plugins="$plugins zsh-syntax-highlighting)"
    #            sed -i "s/^plugins=.*/$plugins/" ~/.zshrc
    #     fi

    #fi   
    cat ./zshrc > ~/.zshrc
}

########## Gnome Settings ##########
gnome_settings() {
    # Ubuntu Dock
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 25

    # Keyboard layout - Logitech K380
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us+alt-intl'), ('xkb', 'br')]"

    # Show battery percentage
    gsettings set org.gnome.desktop.interface show-battery-percentage true

    # Remove trash from dock
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false

    # Manage Windows
    gsettings set org.gnome.shell.app-switcher current-workspace-only true
    gsettings set org.gnome.shell.extensions.dash-to-dock isolate-monitors true

    # Custom shortcuts
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/']" 
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'bluetooth settings'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-control-center bluetooth'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Ctrl><Alt>b'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'flameshot'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command '/usr/bin/flameshot gui'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding 'Print'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'Mute Mic'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'amixer set Capture toggle'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Ctrl><Alt>m'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ name 'Put Focus Next Monitor'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ command 'bash ~/mega/studies/projects/shell-scripts/linux-bootstraper/swap-screens.sh'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ binding '<Super>Tab'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ name 'Sound Settings'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ command 'gnome-control-center sound'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ binding '<Ctrl><Alt>s'
    
    # Change default Shortcuts
    gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"   
    gsettings set org.gnome.shell.keybindings show-screenshot-ui "[]"
}

main() {
    add_apt_repos
    install_apt_apps
    install_non-apt_apps
    config_apps
    gnome_settings
}

set -exo pipefail
main
