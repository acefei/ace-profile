## Installation:
```
curl -sL https://raw.githubusercontent.com/acefei/ace-profile/master/installer/install.sh | sh
```
> You need to modify $HOME/.gitconfig for github user info 


## Feature
- git command completion and git prompt show
- [fzf is a general-purpose command-line fuzzy finder](https://github.com/junegunn/fzf)      
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
- [ripgrep](https://github.com/BurntSushi/ripgrep) is a line-oriented search tool that recursively searches your current directory for a regex pattern.
- [Pyenv](https://github.com/pyenv/pyenv) is Simple Python version management
  - [ext_install](https://github.com/acefei/ace-profile/blob/master/installer/ext_install) will install python 3.7.2 by default, so you want to set back to system default version, please run `pyenv local system`
- Upgrading Tmux to be compatible with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- Vagrantfile for centos7      
- vim8 support (you need to do extra installation: [ext_install](https://github.com/acefei/ace-profile/blob/master/installer/ext_install))
   - [vim pack](https://github.com/acefei/ace-profile/blob/master/installer/vim_pack)

## Vim with plug
Customize [_vimrc](https://github.com/acefei/ace-profile/blob/master/vimrcs/_vimrc) as you wish
    
## Reference
> [.bashrc and .bash_profile](http://tldp.org/LDP/abs/html/sample-bashrc.html)<br>
> [junegunn/dotfiles](https://github.com/junegunn/dotfiles)<br>
> [Vim8 package](https://vi.stackexchange.com/a/11733)<br>
