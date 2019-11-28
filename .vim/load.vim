" load global gitconfig if not found in homedir
if filereadable("/etc/kiorky-dotfiles/.vim/vimrc")
    let g:home = "/etc/kiorky-dotfiles/.vim"
if !filereadable(eval("$HOME")."/.vim/kiorky-dotfiles")
    let &runtimepath = &runtimepath . ",/etc/kiorky-dotfiles/.vim"
    let &runtimepath = &runtimepath . ",/etc/kiorky-dotfiles/.vim/plugins"
    let &runtimepath = &runtimepath . ",/etc/kiorky-dotfiles/.vim/bundle"
    :source /etc/kiorky-dotfiles/.vim/vimrc
endif
endif
