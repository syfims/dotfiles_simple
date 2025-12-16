" ─────────────────────────────────────────────────────────────────
"  BEHAVIOR & EDITOR
" ─────────────────────────────────────────────────────────────────
set noswapfile
set clipboard+=unnamedplus           " Usa clipboard do sistema
set mouse=a                          " Habilita mouse
set number                           " Números de linha
set cursorline                       " Destaca linha atual
set ignorecase                       " Busca case-insensitive
set laststatus=2                     " Barra sempre visível
set showmode                         " Mostra modo
set cmdheight=1                      " Altura do comando
set termguicolors                    " Cores verdadeiras

" Auto-start em Insert Mode
autocmd VimEnter * startinsert

" Lembrar posição do cursor
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

" Salvar ao sair
augroup force_save_on_quit
  autocmd!
  autocmd VimLeavePre * :wa
augroup END

" Clipboard (Wayland)
let g:clipboard = {
      \   'name': 'wl-clipboard',
      \   'copy': { '+': 'wl-copy', '*': 'wl-copy' },
      \   'paste': { '+': 'wl-paste --no-newline', '*': 'wl-paste --no-newline' },
      \   'cache_enabled': 1,
      \ }

" ─────────────────────────────────────────────────────────────────
"  KEYBINDINGS (NANO/NOTEPAD STYLE)
" ─────────────────────────────────────────────────────────────────

" Quit (Ctrl+X)
noremap <C-x> :quit!<CR>
inoremap <C-x> <C-o>:quit!<CR>
vnoremap <C-x> <Esc>:quit!<CR>

" Save (Ctrl+S)
noremap <C-s> :update<CR>
inoremap <C-s> <C-o>:update<CR>

" Copy (Ctrl+C)
vnoremap <C-c> "+y
snoremap <C-c> <C-g>"+y
inoremap <C-c> <Esc>

" Paste (Ctrl+V)
noremap <C-v> "+p
inoremap <C-v> <C-r>+
cnoremap <C-v> <C-r>+

" Select All (Ctrl+A)
noremap <C-a> ggVG"+y
inoremap <C-a> <Esc>ggVG"+y

" Find (Ctrl+F)
noremap <C-f> /
inoremap <C-f> <Esc>/

" Undo/Redo (Ctrl+Z / Ctrl+Y)
noremap <C-z> u
inoremap <C-z> <C-o>u
noremap <C-y> <C-r>
inoremap <C-y> <C-o><C-r>

" File Explorer (Netrw - Ctrl+B)
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 20
let g:netrw_browse_split = 4
let g:netrw_altv = 1
noremap <C-b> :Lexplore<CR>
inoremap <C-b> <C-o>:Lexplore<CR>

" ─────────────────────────────────────────────────────────────────
"  VISUALS (MINIMAL THEME)
" ─────────────────────────────────────────────────────────────────
set background=dark
colorscheme default

" Statusline Limpa
set statusline=%#PmenuSel#\ %f\ %#LineNr#\ %m%r%=%#CursorLine#\ %y\ %l:%c\ %P\ 

" Cores Manuais (Catppuccin-ish)
hi Normal guibg=#1e1e2e guifg=#cdd6f4
hi LineNr guibg=#1e1e2e guifg=#585b70
hi CursorLine guibg=#313244
hi Visual guibg=#45475a
hi StatusLine guibg=#1e1e2e guifg=#cdd6f4
hi Pmenu guibg=#181825 guifg=#cdd6f4
hi PmenuSel guibg=#cba6f7 guifg=#11111b
