" ─────────────────────────────
" 🧱 기본 Neovim 설정
" ─────────────────────────────
set encoding=UTF-8
set fileencodings=UTF-8,CP949
set number
set ruler
set autoindent
set smartindent
set nowrap
set tabstop=4
set shiftwidth=2
set background=dark          " Solarized Dark에 맞춤
set notermguicolors          " macOS 기본 터미널에선 termguicolors 비권장

" ─────────────────────────────
" 📦 플러그인 설치 경로
" ─────────────────────────────
call plug#begin(stdpath('data') . '/plugged')

" 🎨 Solarized 테마 (원본 버전)
Plug 'altercation/vim-colors-solarized'

" 🌲 Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" 🧠 LSP & 자동완성
Plug 'neovim/nvim-lspconfig'
Plug 'glepnir/lspsaga.nvim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" 🔍 Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" 🎨 UI 개선
Plug 'hoob3rt/lualine.nvim'
Plug 'romgrk/barbar.nvim'
Plug 'kyazdani42/nvim-web-devicons'

" 🗂️ 파일 탐색기 / 코드 구조
Plug 'preservim/nerdtree'
Plug 'preservim/tagbar'
Plug 'ryanoasis/vim-devicons'

" ✍️ 자동 괄호
Plug 'cohama/lexima.vim'

" 📝 Markdown 미리보기
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }

call plug#end()

" ─────────────────────────────
" 🎨 테마 적용 (solarized)
" ─────────────────────────────
colorscheme solarized

" 테마 하이라이트를 덮어쓰지 않음 (기본 스타일 그대로 사용)

" ─────────────────────────────
" 🌳 Treesitter 설정
" ─────────────────────────────
lua << EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  }
}
EOF

" ─────────────────────────────
" 🧰 기타 설정 및 키맵
" ─────────────────────────────

" ctags 경로 설정
let g:tagbar_ctags_bin = "/opt/homebrew/bin/ctags"
let g:Tlist_Ctags_Cmd = "/opt/homebrew/bin/ctags"

" Python provider 설정
let g:python3_host_prog = '/usr/local/bin/python3'  " 실제 경로 확인 필요

" 실행 키맵
au FileType python nmap <buffer> <F5> :term python3 %<CR>
au FileType c nmap <buffer> <F5> :term gcc % && ./a.out<CR>

" NerdTree 단축키
nmap <C-n> :NERDTree<CR>
nmap <C-b> :NERDTreeClose<CR>

" 버퍼 이동
nnoremap <C-l> :bnext<CR>
nnoremap <C-h> :bprevious<CR>

" 터미널 열기
nnoremap <C-e> <Cmd>belowright split<CR><Cmd>resize 6<CR><Cmd>terminal<CR>
tnoremap <Esc> <C-\><C-n>

