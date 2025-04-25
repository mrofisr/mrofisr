call plug#begin()

Plug 'morhetz/gruvbox'
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install --frozen-lockfile --production',
  \ 'branch': 'release/0.x'
  \ }
Plug '907th/vim-auto-save'

call plug#end()


" Vim settings based on VSCode configuration

" Font settings (For terminal Vim, configure the terminal emulator font)
" In Neovim, you can configure the font in your terminal emulator
" set guifont=Meslo\LGM\Nerd\Font:h16

" Line numbers & cursor
set number           " Show line numbers
set relativenumber   " Show relative line numbers
set cursorline       " Highlight the current line

" Scrolling & view
set nowrap           " Disable line wrapping
set scrolloff=8      " Keep 8 lines above and below the cursor when scrolling
set sidescroll=1     " Keep scrolling to the left at least 1 column
set scrolljump=3     " Scroll by 3 lines at a time

" Search settings
set ignorecase       " Ignore case when searching
set smartcase        " Override 'ignorecase' if the search term has uppercase letters
set incsearch        " Incremental search
set hlsearch         " Highlight search matches

" Indentation settings
set expandtab        " Use spaces instead of tabs
set tabstop=2        " Set tab width to 2 spaces
set shiftwidth=2     " Set indentation width to 2 spaces
set smartindent      " Automatically indent new lines
set autoindent       " Enable automatic indentation
set softtabstop=2    " Use 2 spaces per indentation level in insert mode

" Line height & spacing
set linespace=1      " Set line spacing to 1 (though Vim has different handling)

" Disable some UI elements (equivalent to VSCode Zen mode)
set guioptions-=m    " Hide the menu bar
set guioptions-=T    " Hide toolbar
set laststatus=2     " Always show the status line
set noshowmode       " Hide mode indicator
set noshowcmd        " Hide command in the bottom bar
set noruler          " Hide ruler (line/column info)

" Status bar and activity bar visibility
set noshowmode       " Don't show mode (Normal/Insert) in the command line

" Autocompletion
set completeopt=menuone,noinsert,noselect " Customize completion menu behavior

" Git integration
" Ensure you have a plugin for Git integration (like fugitive.vim)
" Autocompletion and Git status will be handled by plugins
let g:fugitive_gitlab_domains = ['gitlab.com','github.com']

" Auto-save behavior (handle through plugins like 'auto-save.vim' or 'vim-auto-save')
" For example, to auto-save files when Vim loses focus:
autocmd FocusLost * silent! write

" File types and format settings
autocmd FileType javascript,typescript,typescriptreact,html,json,css setlocal formatoptions+=cro
autocmd FileType javascript,typescript,typescriptreact,html,json,css setlocal tabstop=2 shiftwidth=2

" Format on save (via Prettier)
" You will need a plugin like 'prettier.vim' to enable this functionality
autocmd BufWritePre *.js,*.ts,*.jsx,*.tsx,*.json,*.css,*.html Prettier

" Highlight matching parentheses and brackets
set showmatch

" Enable smooth scrolling for the cursor
set scrolloff=5

" Enable code linting on save (via an appropriate plugin like ale or syntastic)
" For ESLint (assuming you have ale or syntastic set up)
let g:ale_fix_on_save = 1
let g:ale_linters = {'typescript': ['eslint']}
let g:ale_fixers = {'typescript': ['eslint']}

" File explorer location (Configure through NERDTree or a similar plugin)
" You can use a file explorer like NERDTree or vim-vinegar to manage file browsing
" Example:
" map <leader>e :NERDTreeToggle<CR>

" Theme settings
" You can use a theme like 'Oscura Midnight' in Vim with a plugin
" Example: Install a color scheme like 'gruvbox', 'onedark', or 'tokyonight'
colorscheme gruvbox  " or any other color scheme you prefer
set background=dark

" Window settings (title bar customization)
set titlestring=%F    " Show the full file path in the title
set title             " Enable title bar
