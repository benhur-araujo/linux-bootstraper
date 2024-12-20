## Linux Bootstraper
This script is designed to help keep configurations synchronized between computers running Ubuntu 23.10 or to configure the system after a fresh O.S installation

### Usage
```bash
git clone https://github.com/benhur-araujo/linux-bootstraper.git
cd linux-bootstraper
./linux-bootstraper.sh --full  # Install or update everything, and apply configs
./linux-bootstraper.sh --diff  # Install not installed packages, and apply configs
```
### Features
#### General system preferences
- Add current $USER to sudoers file
- Laptop lid behavior - Ignore when closing it
- Set VIM as default text editor

#### Add APT Repositories
- Terraform: HashiCorp Terraform APT repository
- VSCode: Visual Studio Code APT repository
- GitHub CLI: GitHub CLI APT repository

#### APT Packages Installations
- vim-gtk3, tree, git: Essential tools
- zsh, bash-completion: Shell enhancements
- flameshot: Screenshot tool
- tilix: Terminal emulator
- jq, yq, wget, gpg, curl, gnupg, software-properties-common, code, gh, shellcheck: Dev Tools
- Ansible, Terraform: IaC Tools
- apt-transport-https: APT package for secure package handling
- xdotool, chrome-gnome-shell, gnome-browser-connector, xclip, bat, zoxide
- python3-pip, pre-commit, lastpass-cli

### Non-Package Managed Installations
- Google Chrome: Web browser
- Oh My Zsh: Zsh configuration framework
- asdf: Version manager for multiple runtime languages
- Mega: Mega cloud storage client
- kubectl: Kubernetes command-line tool
- Docker: Containerization platform
- Discord: Communication platform
- AWS CLI: Amazon Web Services command-line tool
- AZURE CLI: Microsoft Azure command-line tool
- Kubelogin - A Kubernetes credential (exec) plugin implementing azure authentication
- Terragrunt: Wrapper for Terraform
- Minikube, K9S, helm

### Packages Configurations
- Tilix: Changed many shortcuts and terminal behavior
- Vim: Vim configuration with Terraform plugin
- Zsh: Zsh configurations with autosuggestions and syntax highlighting
- VSCode Extensions: ShellCheck and HashiCorp Terraform

### Gnome Preferences
- Ubuntu Dock settings
- Keyboard layout (Logitech K380)
- Show battery percentage
- Remove trash from the Ubuntu dock
- Manage Windows & Workspaces settings
- Custom shortcuts for Bluetooth, Flameshot, Mute Mic, Screen Swap, and Sound Settings

### Gnome Extensions
- Clipboard History
- Notification Counter

### Notes
- This script assumes Ubuntu 24.04 as the operating system.
- Make sure to review and customize the script based on your requirements.
