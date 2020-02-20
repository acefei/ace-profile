" source this into ~/.vimrc
"Vim-plug initialization {
   let vim_plug_just_installed = 0
   let vim_plug_path = expand('~/.vim/autoload/plug.vim')
   if !filereadable(vim_plug_path)
       echo "Installing Vim-plug..."
       echo ""
       silent !mkdir -p ~/.vim/autoload
       silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
       let vim_plug_just_installed = 1
   endif

   " manually load vim-plug the first time
   if vim_plug_just_installed
       :execute 'source '.fnameescape(vim_plug_path)
   endif

   " Active plugins
   " Plugins from github repos
   call plug#begin('~/.vim/plugged')
       " Python mode (indentation, doc, refactor, lints, code checking, motion and
       " operators, highlighting, run and ipdb breakpoints)
       Plug 'python-mode/python-mode'
        
       " Autocompletion library
       "Plug 'maralla/completor.vim'
        
       " Lint check
       Plug 'w0rp/ale'

       " Code and files fuzzy finder
       Plug 'ctrlpvim/ctrlp.vim'

       " Better file browser
       Plug 'scrooloose/nerdtree'

       " Code Comment functions so powerful
       Plug 'scrooloose/nerdcommenter'

       " Class/module browser
       Plug 'majutsushi/tagbar'

       "  Code snippet
       "Plug 'SirVer/ultisnips'
       " Snippets are separated from the engine. Add this if you want them:
       "Plug 'honza/vim-snippets'
       
       " Insert or delete brackets, parens, quotes in pair.
       Plug 'jiangmiao/auto-pairs'
       
   call plug#end()

   " Install plugins the first time vim runs
   if vim_plug_just_installed
       echo "Installing Bundles, please ignore key map error messages"
       :PlugInstall
   endif
"}
