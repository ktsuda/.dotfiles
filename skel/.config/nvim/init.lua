-- never load plugins when you commit
if vim.env.GIT_EXEC_PATH ~= nil and vim.env.GIT_EXEC_PATH ~= '' then
  return
end

-- helpers
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt
local api = vim.api

local function map(mode, lhs, rhs, _opts)
  local opts = {noremap = true}
  if _opts then
    opts = vim.tbl_extend('force', opts, _opts)
  end
  api.nvim_set_keymap(mode, lhs, rhs, opts)
end

local function bmap(bufnr, mode, lhs, rhs, _opts)
  local opts = {noremap = true, silent = true}
  if _opts then
    opts = vim.tbl_extend('force', opts, _opts)
  end
  api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
end

-- plugins
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system(
    {'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path}
  )
end

cmd 'packadd packer.nvim'
require('packer').startup(function(use)
  use {'wbthomason/packer.nvim', opt = true}
  use {'vim-airline/vim-airline'}
  use {'preservim/nerdtree'}
  use {'gruvbox-community/gruvbox'}
  use {'nvim-lua/completion-nvim'}
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use {'neovim/nvim-lspconfig'}
  use {
    'ojroques/nvim-lspfuzzy',
    requires = {
      {'junegunn/fzf', run = fn['fzf#install']},
      {'junegunn/fzf.vim'},
    }
  }
  use {'junegunn/vim-easy-align'}
  use {'tpope/vim-surround'}
  use {'dhruvasagar/vim-table-mode'}
  use {'SirVer/ultisnips'}
  use {'honza/vim-snippets'}
  use {'thinca/vim-quickrun'}
  use {'iberianpig/tig-explorer.vim'}
  use {'rbgrouleff/bclose.vim'}
  use {
    'iamcco/markdown-preview.nvim',
    ft = {'markdown'},
    run = 'cd app && yarn install'
  }
  use {'wakatime/vim-wakatime'}
end)

cmd 'autocmd BufWritePost packer.lua PackerCompile'

-- options
cmd 'colorscheme gruvbox'
opt.number = true
opt.relativenumber = true
opt.background = 'dark'
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.laststatus = 2
opt.completeopt = {'menuone', 'noinsert', 'noselect'}
opt.hidden = true
opt.ignorecase = true
opt.smartcase = true
opt.smartindent = true
opt.splitbelow = true
opt.splitright = true
opt.wildmode = {'list', 'longest'}
opt.wrap = false
opt.hlsearch = true
opt.incsearch = true
opt.autoindent = true
opt.textwidth = 78
opt.formatoptions = 'roqnlj'

cmd 'set clipboard&'
if fn.has('mac') then
  opt.clipboard:append {'unnamed'}
elseif fn.has('win64') then
  opt.clipboard:append {'unnamed'}
elseif fn.has('win32') then
  opt.clipboard:append {'unnamed'}
else
  opt.clipboard:append {'unnamedplus'}
end

-- mappings
g.mapleader = ' '
map('', '<leader>c', '"+y')
map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<S-Tab>"', {expr = true})
map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})
map('n', '[q', ':cprevious<CR>')
map('n', ']q', ':cnext<CR>')
map('n', '\'q', ':cclose<CR>')
map('n', 'Y', 'y$')
map('n', 'th', '<Plug>AirlineSelectPrevTab', {noremap = false})
map('n', 'tl', '<Plug>AirlineSelectNextTab', {noremap = false})
map('n', '<C-p>', ':GFiles<CR>')
map('n', '<C-n>', ':Files<CR>')
map('', '<C-e>', ':NERDTreeToggle<CR>')
map('n', '<leader>t', ':TigOpenProjectRootDir<CR>')
map('n', '<leader>T', ':TigOpenCurrentFile<CR>')
map('n', '<leader>g', ':TigGrep<CR>')
map('n', '<leader>b', ':TigBlame<CR>')

if fn.has('mac') then
  map('',  '∆', '<C-w>j')
  map('i', '∆', '<Esc><C-w>j')
  map('t', '∆', '<C-\\><C-n><C-w>j')
  map('',  '˚', '<C-w>k')
  map('i', '˚', '<Esc><C-w>k')
  map('t', '˚', '<C-\\><C-n><C-w>k')
  map('',  '˙', '<C-w>h')
  map('i', '˙', '<Esc><C-w>h')
  map('t', '˙', '<C-\\><C-n><C-w>h')
  map('',  '¬', '<C-w>l')
  map('i', '¬', '<Esc><C-w>l')
  map('t', '¬', '<C-\\><C-n><C-w>l')
end

-- airline
g['airline#extensions#tabline#enabled'] = 1
g['airline#extensions#tabline#buffer_idx_mode'] = 1

-- fzf
g.fzf_buffers_jump = 1

-- nerdtree
api.nvim_set_var('NERDTreeShowHidden', 1)

-- vim-table-mode
g.table_mode_corner='|'

-- treesitter
local treesitter = require('nvim-treesitter.configs')
treesitter.setup {
  ensure_installed = 'maintained',
  highlight = {enable = true},
  indent = {enable = true},
}

-- lsp
g.lsp_diagnostics_enabled = 1
g.lsp_diagnostics_echo_cursor = 1
g.completion_enable_auto_popup = 1

local lsp = require('lspconfig')
local lspfuzzy = require('lspfuzzy')

local completion_callback = function(client, bufnr)
  bmap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
  bmap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.declaration()<CR>')
  bmap(bufnr, 'n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>')
  bmap(bufnr, 'n', '<leader>i', '<cmd>lua vim.lsp.buf.implementation()<CR>')
  bmap(bufnr, 'n', '<leader>r', '<cmd>lua vim.lsp.buf.references()<CR>')
  bmap(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>')
  bmap(bufnr, 'n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
  bmap(bufnr, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
  bmap(bufnr, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
  bmap(bufnr, 'n', '<leader>m', '<cmd>lua vim.lsp.buf.rename()<CR>')
  require('completion').on_attach(client)
end

local servers = {
  'ansiblels',      -- yarn global add ansible-language-server
  'ccls',           -- brew install ccls
  'cmake',          -- pip install cmake-language-server
  'dockerls',       -- npm i -g dockerfile-language-server-nodejs
  'gopls',          -- brew install gopls
  'jsonls',         -- npm i -g vscode-langservers-extracted
  'pylsp',          -- npm i python-lsp-server
  'texlab',         -- cargo install --git https://github.com/latex-lsp/texlab.git --locked
  'vimls',          -- yarn global add vim-language-server
  'vls',            -- yarn global add vls
  'yamlls',         -- npm i -g yaml-language-server
}

for _, srv in ipairs(servers) do
  lsp[srv].setup {
    on_attach = completion_callback,
    flags = {debounce_text_changes = 150},
  }
end

-- sumneko_lua
local system_name
if fn.has('mac') then
  system_name = 'macOS'
elseif fn.has('unix') then
  system_name = 'Linux'
elseif fn.has('win32') then
  system_name = 'Windows'
else
  print('Unsupported system for sumneko')
end

local sumneko_root_path = vim.env.HOME..'/.ghq/src/github.com/sumneko/lua-language-server'
local sumneko_binary = sumneko_root_path..'/bin/'..system_name..'/lua-language-server'
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

lsp.sumneko_lua.setup {
  cmd = {sumneko_binary, '-E', sumneko_root_path .. '/main.lua'};
  settings = {
    Lua = {
      runtime = {version = 'LuaJIT', path = runtime_path},
      diagnostics = {globals = {'vim'}},
      workspace = {library = api.nvim_get_runtime_file('', true)},
      telemetry = {enable = false},
    },
  },
}

-- zeta_note
lsp.zeta_note.setup {
  cmd = {vim.env.HOME .. '/bin/zeta_note'}
}

-- lsp fuzzy
lspfuzzy.setup {}

-- markdown-preview
g.mkdp_auto_start = 0
g.mkdp_auto_close = 1
g.mkdp_refresh_slow = 1

-- snippets
g.UltiSnipsExpandTrigger = '<Tab>'
g.UltiSnipsJumpForwardTrigger = '<C-f>'
g.UltiSnipsJumpBackwardTrigger = '<C-b>'
g.UltiSnipsEditSplit = 'horizontal'

-- configuration file
map('n', '<leader>,', ':e '..vim.env.MYVIMRC..'<CR>')
map('n', '<leader>.', ':luafile '..vim.env.MYVIMRC..'<CR>')
