# stripe.vim

## Introduction

Stripe color for backgroup.

## Installation

[Neobundle](https://github.com/Shougo/neobundle.vim) / [Vundle](https://github.com/gmarik/Vundle.vim) / [vim-plug](https://github.com/junegunn/vim-plug)

```vim
NeoBundle 'osyo-manga/vim-stripe'
Plugin 'osyo-manga/vim-stripe'
Plug 'osyo-manga/vim-stripe'
```

[pathogen](https://github.com/tpope/vim-pathogen)

```
git clone https://github.com/osyo-manga/vim-stripe ~/.vim/bundle/vim-hopping
```

## Setting

```vim
" Must setting highlight

hi EvenLbg ctermbg=235 guibg=#090909
let g:stripe_config = {
\	"group_odd" : "EvenLbg"
\}

```
