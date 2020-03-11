![sync to gitee](https://github.com/acefei/ace-profile/workflows/sync%20to%20gitee/badge.svg)

## Installation:
### Linux 
```
curl -fsSL https://raw.githubusercontent.com/acefei/ace-profile/master/installer/install.sh | bash
```
or
```
wget -qO- https://raw.githubusercontent.com/acefei/ace-profile/master/installer/install.sh | bash
```
#### In GFW
```
curl -fsSL https://gitee.com/acefei/ace-profile/raw/master/installer/install.sh | bash -s gitee
```

> Note:
> 1. Sometime the cmd dosn't work on WSL, it might be caused by DOS line-endings, that need add `tr -d '\r'` ahead of `bash`, like 
> ``` wget -qO- https://raw.githubusercontent.com/acefei/ace-profile/master/installer/install.sh | tr -d '\r' | bash ```
> 2. Using the pipe would install everythings in the stage2, if you want to select some of them, it'd better run it by two steps. 
> ``` wget https://raw.githubusercontent.com/acefei/ace-profile/master/installer/install.sh && bash install.sh ```
> 3. You need to modify $HOME/.gitconfig for github user info 

### Windows
Press `Win + x + i`, then run following cmd.
```
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/acefei/ace-profile/master/installer/setup-win.ps1'))
```
## Extensions
- [ShellCheck, a static analysis tool for shell scripts](https://github.com/koalaman/shellcheck)
  - [Vim wrapper for ShellCheck](https://github.com/itspriddle/vim-shellcheck)
- [fzf is a general-purpose command-line fuzzy finder](https://github.com/junegunn/fzf)  
  - add the alias `vigo` is used to open selected file from workspace
  - add the alias `cdgo` is used to cd into selected directory from workspace
  - the workspace is $HOME by default, you might update it in ~/.bashrc
```
    CTRL-T - Paste the selected files and directories onto the command line
        Set FZF_CTRL_T_COMMAND to override the default command
        Set FZF_CTRL_T_OPTS to pass additional options
    CTRL-R - Paste the selected command from history onto the command line
        Sort is disabled by default to respect chronological ordering
        Press CTRL-R again to toggle sort
        Set FZF_CTRL_R_OPTS to pass additional options
    ALT-C - cd into the selected directory
        Set FZF_ALT_C_COMMAND to override the default command
        Set FZF_ALT_C_OPTS to pass additional options
```
    
- [Facebook PathPicker](https://github.com/facebook/PathPicker) is a simple command line tool that solves the perpetual problem of selecting files out of bash output.
- git command completion and git prompt show
  - Text-mode interface for git: [tig]](https://github.com/jonas/tig)
- vim8 support 
   - [vim pack](https://github.com/acefei/ace-profile/blob/master/utility/vim_pack) is used to install vim plugins.
   - [bash support plugin](https://github.com/vim-scripts/bash-support.vim)
   - [_vimrc](https://github.com/acefei/ace-profile/blob/master/vimrcs/_vimrc)

Now we use Centos 8 as devbox ([How to create it](https://github.com/acefei/ace-osinstaller)), so will remove below tools. 
<s>
- Upgrading Tmux to be compatible with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Pyenv](https://github.com/pyenv/pyenv) is Simple Python version management
  - [ext_install](https://github.com/acefei/ace-profile/blob/master/installer/ext_install) will install python 3.7.2 by default, so you want to set back to system default version, please run `pyenv local system`
</s>
    

## Reference
> [bash cheatsheet](https://github.com/rstacruz/cheatsheets/blob/master/bash.md)
> [.bashrc and .bash_profile](http://tldp.org/LDP/abs/html/sample-bashrc.html)<br>
> [junegunn/dotfiles](https://github.com/junegunn/dotfiles)<br>
> [Vim8 package](https://vi.stackexchange.com/a/11733)<br>
> [Record and share your terminal sessions](https://asciinema.org/)<br>
> [hotkey for bash-support.vim](https://lug.fh-swf.de/vim/vim-bash/bash-hotkeys.pdf)
