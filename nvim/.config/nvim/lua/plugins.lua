require("lazy").setup({
    -- lsp
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",        -- 管理 LSP 伺服器的工具
    "williamboman/mason-lspconfig.nvim", -- 橋接 Mason 與 lspconfig

    -- Java
    {
        "nvim-java/nvim-java",
        config = function()
            require("java").setup()
            vim.lsp.enable("jdtls")
        end,
    },

    -- 自動補全 UI
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",

    -- Git difference
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim",
        },
        config = true,
    },

    -- Keymap hints
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {},
    },

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
                lsp_fallback = "never",
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

    -- Bookmarks
    {
        "MattesGroeger/vim-bookmarks",
        dependencies = {
            "tom-anders/telescope-vim-bookmarks.nvim",
        },
        config = function()
            vim.g.bookmark_save_per_working_dir = 1
            vim.g.bookmark_auto_save = 1
            require("telescope").load_extension("vim_bookmarks")
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
keymap.set("n", "<leader>fm", function()
    require("telescope").extensions.vim_bookmarks.all({
        attach_mappings = function(_, map)
            local bookmark_actions = require("telescope").extensions.vim_bookmarks.actions
            -- 在 Normal 模式下 (按 Esc 後)，按 dd 刪除書籤
            map("n", "dd", bookmark_actions.delete_selected_or_at_cursor)
            -- 在 Insert 模式下 (打字搜尋時)，按 Ctrl+d 刪除書籤
            map("i", "<C-d>", bookmark_actions.delete_selected_or_at_cursor)
            return true
        end,
    })
end, { desc = "搜尋標籤" })

-- Git
local gs = require("gitsigns")
keymap.set("n", "<leader>gb", gs.blame_line, { desc = "Git Blame (查看這行是誰寫的)" })
keymap.set("n", "<leader>gd", gs.preview_hunk, { desc = "Git Diff (查看這塊改了什麼)" })
keymap.set("n", "<leader>gh", builtin.git_commits, { desc = "Git History (查看 Commit 紀錄)" })
keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "退回 Git 區塊變更" })
keymap.set("n", "<leader>gR", gs.reset_buffer, { desc = "退回整個檔案" })
