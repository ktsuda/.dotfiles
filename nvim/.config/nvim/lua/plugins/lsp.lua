return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    {
      'williamboman/mason.nvim',
      build = ':MasonUpdate',
      cmd = 'Mason',
      opts = {},
    },
    { 'williamboman/mason-lspconfig.nvim', opts = {} },
    { 'hrsh7th/cmp-nvim-lsp' },
    {
      'j-hui/fidget.nvim',
      opts = {
        notification = {
          window = {
            winblend = 20,
          },
        },
      },
    },
    { 'folke/neodev.nvim', opts = {} },
  },
  config = function()
    local on_attach = function(client, bufnr)
      vim.lsp.set_log_level('off')
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
      local function nmap(l, r, desc)
        if desc then
          desc = 'LSP: ' .. desc
        end
        vim.keymap.set('n', l, r, { buffer = bufnr, desc = desc })
      end
      nmap('gD', vim.lsp.buf.declaration, '[g]oto [D]eclaration')
      nmap('gd', vim.lsp.buf.definition, '[g]oto [d]efinition')
      nmap('K', vim.lsp.buf.hover)
      nmap('gi', vim.lsp.buf.implementation, '[g]oto [i]mplementation')
      nmap('gr', vim.lsp.buf.references, '[g]oto [r]eferences')
    end
    local servers = {
      clangd = {},
      pyright = {
        python = {
          analysis = { typeCheckingMode = 'off' },
        },
      },
      lua_ls = {
        Lua = {
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
          diagnostics = { globals = { 'vim' } },
        },
      },
      gopls = {},
      tailwindcss = {},
      tsserver = {
        filetypes = { 'typescript', 'typescriptreact', 'typescript.tsx', 'javascript', 'javascriptreact' },
        cmd = { 'typescript-language-server', '--stdio' },
      },
    }
    -- local flags = { debounce_text_chages = 150 }
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    local mason_lspc = require('mason-lspconfig')
    mason_lspc.setup({
      ensure_installed = vim.tbl_keys(servers),
    })
    mason_lspc.setup_handlers({
      function(server_name)
        require('lspconfig')[server_name].setup({
          capabilities = capabilities,
          on_attach = on_attach,
          -- flags = flags,
          settings = servers[server_name],
          filetypes = (servers[server_name] or {}).filetypes,
        })
      end,
    })
  end,
}
