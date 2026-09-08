# dotfiles

My installation and configuration files.

## Install

- Prerequisites: git

```bash
cd ~
git clone https://github.com/lucasrcezimbra/dotfiles.git .dotfiles
cd .dotfiles
./install.sh
```

## Omarchy wallpaper automation

The first Ansible-managed workstation feature installs a Peapix wallpaper downloader and enables wallpaper rotation every 30 minutes.

Install Ansible and apply the local playbook from the repository root:

```bash
omarchy pkg add ansible
ansible-playbook ansible/playbook.yml
```

Download and immediately set a new wallpaper:

```bash
,wallpaper-download
```

Inspect or trigger rotation manually:

```bash
systemctl --user status wallpaper-rotate.timer
omarchy theme bg next
```

The playbook manages user files and services. Do not run it with `sudo`. Running it again should report `changed=0` when the desired state is already present.

## Tools
- [ast-grep](https://github.com/ast-grep/ast-grep) - abstract syntax tree grep
- [aws-vault](https://github.com/99designs/aws-vault) to manage AWS credentials
- Browsers: Chrome and Firefox
- [btop](https://github.com/aristocratos/btop) - replacement for `top`
- [caligula](https://github.com/ifd3f/caligula) - TUI to create bootable ISOs
- [delta](https://github.com/dandavison/delta) - syntax-highlighting pager for `git` and `grep` outputs and replacement for `diff`
- [difftastic](https://difftastic.wilfred.me.uk/) - diff tool that understands syntax
- [diskonaut](https://github.com/imsnif/diskonaut) - disk space analyzer/navigator
- [Docker](https://www.docker.com/)
- [eza](https://github.com/eza-community/eza) - replacement for `ls`
- [fd](https://github.com/sharkdp/fd) - replacement for `find`
- [Flameshot](https://flameshot.org/) for screenshots
- [Flatpak](https://www.flatpak.org/) and [Snap](https://snapcraft.io/) to install apps
- [Git](https://git-scm.com/) + [GitHub CLI](https://cli.github.com/)
- [llm](https://github.com/simonw/llm) to access LLMs from the command-line
- [LazyVim](http://www.lazyvim.org/) - editor/IDE
- [mergiraf](https://mergiraf.org/) - Git merge conflict solver
- [mise-en-place](https://github.com/jdx/mise) to manage dev tool versions (Node, Python, Terraform, etc)
- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) + many plugins - shell
- [plocate](https://plocate.sesse.net/) to search files
- [ripgrep](https://github.com/BurntSushi/ripgrep) - replacement for `grep`
- [sd](https://github.com/chmln/sd) - replacement for `sed`
- [Solaar](https://github.com/pwr-Solaar/Solaar) to manage Logitech devices
- [Spotify for Linux](https://www.spotify.com/us/download/linux) for music
- [Starship](https://starship.rs/) - shell prompt
- [WezTerm](https://github.com/wez/wezterm) - terminal emulator
- [Zeal](https://zealdocs.org/) - offline software documentation
- [Zoom](http://zoom.com) for meetings
- [zoxide](https://github.com/ajeetdsouza/zoxide) - replacement for `cd` and autojump

### Experiments
- [harlequin](https://harlequin.sh/) - TUI for SQL
- [posting](https://posting.sh/) - TUI for API clients
- [ripgrep-all](https://github.com/phiresky/ripgrep-all) - ripgrep for PDFs, E-Books, Office documents, zip, tar.gz, etc.
