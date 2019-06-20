## Installation:
```
curl -sL https://raw.githubusercontent.com/acefei/ace-profile/master/installer/install.sh | sh
```
> NOTE:
> 1. You need to modify $HOME/.gitconfig for github user info 
> 2. There are two stage on installation, the first stage is very fast for setting some tools, the second stage will make and install tools that would take more time.
  you might complete the installation at the end of the first stage by CTRL+C.


## Feature
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
  - add the alias `vigo` is used to open selected file from workspace
  - add the alias `cdgo` is used to cd into selected directory from workspace
  - the workspace is $HOME by default, you might update it in ~/.bashrc
- [Facebook PathPicker](https://github.com/facebook/PathPicker) is a simple command line tool that solves the perpetual problem of selecting files out of bash output.
- [Pyenv](https://github.com/pyenv/pyenv) is Simple Python version management
  - [ext_install](https://github.com/acefei/ace-profile/blob/master/installer/ext_install) will install python 3.7.2 by default, so you want to set back to system default version, please run `pyenv local system`
- Upgrading Tmux to be compatible with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- git command completion and git prompt show
- vim8 support 
   - [vim pack](https://github.com/acefei/ace-profile/blob/master/utility/vim_pack) is used to install vim plugins.
   - [_vimrc](https://github.com/acefei/ace-profile/blob/master/vimrcs/_vimrc)
    
## Reference
> [.bashrc and .bash_profile](http://tldp.org/LDP/abs/html/sample-bashrc.html)<br>
> [junegunn/dotfiles](https://github.com/junegunn/dotfiles)<br>
> [Vim8 package](https://vi.stackexchange.com/a/11733)<br>
