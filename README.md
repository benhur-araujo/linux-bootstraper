## Linux Bootstraper
This script is designed to help keep configurations synchronized between computers running Ubuntu 26.04, or to configure the system after a fresh O.S installation.

### Usage
```bash
git clone https://github.com/benhur-araujo/linux-bootstraper.git
cd linux-bootstraper
./linux_bootstraper.sh --full  # Install or update everything, and apply configs
./linux_bootstraper.sh --diff  # Install only missing packages, and apply configs (default)
```
Running the script with no argument is equivalent to `--diff`.

### Features
#### General system preferences
- Add current `$USER` to the sudoers file (passwordless sudo)
- Laptop lid behavior - ignore when closing it
- Disable IPv6 via `/etc/sysctl.d`
- Create `~/.claude` soft-links to the `ai-workflow` project (ralph, docs, CLAUDE.md, skills)

#### Add APT Repositories
- pgAdmin: PostgreSQL admin tool APT repository
- Terraform: HashiCorp Terraform APT repository
- VSCode: Visual Studio Code APT repository
- GitHub CLI: GitHub CLI APT repository
- Glow: Charm CLI markdown renderer APT repository
- 1Password: 1Password APT repository

#### APT Packages Installations
- vim-gtk3, tree, git: Essential tools
- zsh, bash-completion: Shell enhancements
- flameshot: Screenshot tool
- tilix: Terminal emulator
- jq, yq, wget, gpg, curl, gnupg, software-properties-common, code, gh, shellcheck, bat, glow, pre-commit: Dev tools
- ansible, terraform: IaC tools
- apt-transport-https: APT package for secure package handling
- xdotool, chrome-gnome-shell, gnome-browser-connector, xclip, zoxide
- openconnect, nmap: Networking tools
- python3-pip, python3.14-venv, python3-tk: Python tooling
- pgadmin4-desktop: PostgreSQL admin desktop client
- 1password-cli: 1Password command-line tool

### Non-Package Managed Installations
- Google Chrome: Web browser
- Oh My Zsh: Zsh configuration framework
- asdf: Version manager for multiple runtime languages (latest tag)
- kubectl: Kubernetes command-line tool
- Docker: Containerization platform
- AZURE CLI: Microsoft Azure command-line tool
- Kubelogin: A Kubernetes credential (exec) plugin implementing Azure authentication
- Terragrunt: Wrapper for Terraform
- Terraform-docs: Documentation generator for Terraform modules
- K9S: Kubernetes cluster TUI (latest release)
- ArgoCD CLI: Argo CD command-line tool (latest release)
- Minikube: Local Kubernetes cluster
- Helm: Kubernetes package manager
- Claude CLI: Anthropic Claude Code CLI

### Packages Configurations
- Tilix: Set as default terminal, appearance tweaks, and many custom shortcuts
- Vim: Vim configuration with Terraform plugin
- Zsh: Zsh configuration with autosuggestions, syntax highlighting, and kubectl autocomplete
- Git: Global user name and email

### Gnome Preferences
- Ubuntu Dock settings
- Show battery percentage
- Never auto-suspend (on battery or AC)
- Remove trash from the Ubuntu dock
- Manage Windows & Workspaces settings (4 fixed workspaces, custom switch/move shortcuts)
- Custom shortcuts for Bluetooth, Flameshot, Mute Mic, and Sound Settings
- Change default shortcuts (Home, switch-applications, screenshot UI)
- Disable Desktop Icons NG (DING) extension

### Gnome Extensions
- Clipboard History
- Notification Counter
- Dash to Panel
- Space Bar

### Notes
- This script assumes Ubuntu 26.04 as the operating system.
- Make sure to review and customize the script based on your requirements.
