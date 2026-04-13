require("lazy").setup({
    -- lsp
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",        -- 管理 LSP 伺服器的工具
    "williamboman/mason-lspconfig.nvim", -- 橋接 Mason 與 lspconfig

    -- 自動補全 UI
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",

    -- Python
    {
        "linux-cultist/venv-selector.nvim",
        dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap" },
        config = true,
    },

    -- Treesitter 語法高亮
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        build = ":TSUpdate",
        config = function()
            local status, configs = pcall(require, "nvim-treesitter.configs")
            if not status then
                return
            end
            configs.setup({
                ensure_installed = { "c", "python", "lua", "vim", "go", "markdown" },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
        textobjects = {
            move = {
                enable = true,
                set_jumps = true,
                goto_next_start = {
                    ["]]"] = "@function.outer",
                    ["]m"] = "@class.outer",
                },
                goto_previous_start = {
                    ["[["] = "@function.outer",
                    ["[m"] = "@class.outer",
                },
            },
        },
    },

    -- Git
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end,
    },

    -- 語法格式化
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                python = { "ruff_organize_imports", "ruff_format" },
                c = { "clang-format" },
                cpp = { "clang-format" },
                sh = { "shfmt" },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        },
    },

    -- 自動補全括號
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
    },

    -- 主題
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin-frappe")
        end,
    },

    -- 搜尋
    {
        "nvim-telescope/telescope.nvim",
        version = "*",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
    },

    -- 代碼修復預覽
    {
        "aznhe21/actions-preview.nvim",
        config = function()
            vim.keymap.set({ "v", "n" }, "<leader>ca", require("actions-preview").code_actions)
        end,
    },
})

-- Telescope Shortcut
local keymap = vim.keymap
local builtin = require("telescope.builtin")
keymap.set("n", "<leader>ff", builtin.find_files, { desc = "搜尋檔案" })
keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "最近開啟的檔案" })
keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "搜尋代碼" })
keymap.set("n", "<leader>fb", builtin.buffers, { desc = "已開啟的 Buffer" })
keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "全域字串搜尋" })

-- Git
local gs = require("gitsigns")
keymap.set("n", "<leader>gb", gs.blame_line, { desc = "Git Blame (查看這行是誰寫的)" })
keymap.set("n", "<leader>gd", gs.preview_hunk, { desc = "Git Diff (查看這塊改了什麼)" })
keymap.set("n", "<leader>gh", builtin.git_commits, { desc = "Git History (查看 Commit 紀錄)" })
