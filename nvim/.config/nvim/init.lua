-- 1. 基礎設定
vim.g.mapleader = " "  -- 設定 Leader Key 為空白鍵
vim.g.maplocalleader = " "
vim.opt.number = true   -- 顯示行號
vim.opt.relativenumber = true -- 顯示相對行號（Vim 跳轉神技）
vim.opt.shiftwidth = 4  -- 縮排 4 格
vim.opt.expandtab = true -- 將 Tab 轉為空白
vim.opt.termguicolors = true

-- 2. Bootstrap lazy.nvim (自動安裝外掛管理器)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 3. 安裝外掛
require("lazy").setup({
  -- LSP 核心
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",           -- 管理 LSP 伺服器的工具
  "williamboman/mason-lspconfig.nvim", -- 橋接 Mason 與 lspconfig
  
  -- 自動補全 UI
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "L3MON4D3/LuaSnip",
  
  -- Python 專用功能
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap" },
    config = true
  },

  -- 語法高亮
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- 使用 pcall (protected call) 來防止模組找不到時直接崩潰
      local status, configs = pcall(require, "nvim-treesitter.configs")
      if not status then
          -- 如果是新版 Treesitter (v1.0+)，可能不需要 .configs
          -- 我們直接嘗試基本的 setup 或是跳過舊版寫法
          return 
      end
      configs.setup({
        ensure_installed = { "python", "lua", "vim", "go", "markdown" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Python 格式化
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" }, -- 使用 ruff 來格式化 Python
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-frappe") -- 使用 mocha 暗色主題
  end,
  },

  {
    'nvim-telescope/telescope.nvim', version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- optional but recommended
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    }
  },
})

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "basedpyright" } -- 自動安裝 Python LSP
})

local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- 設定 Python LSP
lspconfig.basedpyright.setup({
    capabilities = capabilities,
    handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
            border = "rounded",
        }),
    },
    settings = {
        basedpyright = {
            analysis = {
                typeCheckingMode = "basic", -- 或是 "standard"
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
            }
        }
    }
})

-- C/C++ LSP 設定
lspconfig.clangd.setup({
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
})

local keymap = vim.keymap

-- LSP 快捷鍵
keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "跳到定義" })
keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "顯示文檔" })
keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "重命名" })
keymap.set('n', 'se', vim.diagnostic.open_float, { desc = "顯示錯誤" })
keymap.set("", "<Space>", "<Nop>", { silent = true, remap = false })

-- Telescope
local builtin = require('telescope.builtin')
keymap.set("n", "<leader>ff", builtin.find_files, { desc = "搜尋檔案" } )
keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "最近開啟的檔案" } )
keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "搜尋代碼" } )
keymap.set("n", "<leader>fb", builtin.buffers, { desc = "已開啟的 Buffer" } )
keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "全域字串搜尋"} )

-- 快速執行 Python Script (這就是你要的！)
-- 按 <leader>r 即可在下方開啟終端機並執行當前檔案
keymap.set('n', '<leader>r', ':split | term python3 %<CR>', { desc = "執行 Python 腳本" })

-- 快速離開終端機模式 (按下 Esc 即可回到 Normal 模式)
keymap.set('t', '<Esc>', [[<C-\><C-n>]])

local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- 支援代碼片段
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(), -- 手動觸發補全
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- 按下 Enter 確認選取
    ['<Tab>'] = cmp.mapping.select_next_item(), -- Tab 下一個
    ['<S-Tab>'] = cmp.mapping.select_prev_item(), -- Shift+Tab 上一個
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' }, -- 這是最重要的：來源是 LSP
    { name = 'luasnip' },  -- 代碼片段
  }, {
    { name = 'buffer' },   -- 當前檔案的文字
  })
})
