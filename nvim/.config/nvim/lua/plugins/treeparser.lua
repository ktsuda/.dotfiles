local utils = require('utils.fuzzyfinder')

return {
  'nvim-treesitter/nvim-treesitter',
  event = { 'BufReadPre', 'BufNewFile' },
  keys = {
    { '<leader>pt', utils.custom('treesitter'), desc = '[p]arse [t]ree' },
  },
  build = function()
    pcall(require('nvim-treesitter.install').update({ with_sync = true }))
  end,
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        'c',
        'cmake',
        'cpp',
        'diff',
        'dockerfile',
        'go',
        'javascript',
        'json',
        -- 'latex',
        'lua',
        'make',
        'markdown',
        'python',
        'ruby',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
      },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    })
  end,
}
