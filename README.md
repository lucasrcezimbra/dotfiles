# dotfiles

Installation and configuration files for my Debian + XFCE.


## Install
```bash
cd ~
sudo apt update -y && sudo apt install -y git
git clone git@github.com:lucasrcezimbra/dotfiles.git .dotfiles
cd .dotfiles
sh ./install.sh
```

## Tools
- [aws-vault](https://github.com/99designs/aws-vault) to manage AWS credentials
- [btop](https://github.com/aristocratos/btop) - replacement for `top`
- [Docker](https://www.docker.com/)
- [eza](https://github.com/eza-community/eza) - replacement for `ls`
- [Flatpak](https://www.flatpak.org/) and [Snap](https://snapcraft.io/) to install apps
- [Git](https://git-scm.com/) + [GitHub CLI](https://cli.github.com/)
- [llm](https://github.com/simonw/llm) to access LLMs from the command-line
- [LunarVim](https://www.lunarvim.org/) - editor/IDE
    - GitHub [copilot](https://github.com/zbirenbaum/copilot.lua)
    - [markdown-preview](https://github.com/iamcco/markdown-preview.nvim)
    - [neotest](https://github.com/nvim-neotest/neotest) to run tests inside the editor
    - [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python) to debug inside the editor
- [mise-en-place](https://github.com/jdx/mise) to manage dev tool versions (Node, Python, Terraform, etc)
- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) + many plugins - shell
- [plocate](https://plocate.sesse.net/) to search files
- [Starship](https://starship.rs/) - shell prompt
- [WezTerm](https://github.com/wez/wezterm) - terminal emulator
- [Zeal](https://zealdocs.org/) - offline software documentation
- [zoxide](https://github.com/ajeetdsouza/zoxide) - replacement for `cd` and autojump
