require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "basedpyright",
        "clangd",
        "gopls",
        "lua_ls",
        "dockerls",
        "yamlls",
        "bashls",
    },
    automatic_installation = true,
})

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Python
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
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
            },
        },
    },
})

-- C/C++
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

-- Go
lspconfig.gopls.setup({
    capabilities = capabilities,
    settings = {
        gopls = {
            analysis = {
                unusedparams = true, -- 未使用參數
                shadow = true, -- 參數覆蓋
                unusedwrite = true, -- 未使用寫入
            },
            staticcheck = true, -- 靜態分析
            gofumpt = true, -- 格式化分析
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
            semanticTokens = true, -- 語意著色
        },
    },
})

-- Lua
lspconfig.lua_ls.setup({
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = { enable = false },
        },
    },
})

-- Docker
lspconfig.dockerls.setup({
    capabilities = capabilities,
})

-- Docker compose
lspconfig.docker_compose_language_service.setup({
    capabilities = capabilities,
})

-- YAML
lspconfig.yamlls.setup({
    capabilities = capabilities,
    settings = {
        yaml = {
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://json.schemastore.org/github-action.json"] = "/.github/actions/*",
            },
        },
    },
})

-- Bash
lspconfig.bashls.setup({
    capabilities = capabilities,
    filetypes = { "sh", "bash" },
})

-- Auto import
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
        local params = vim.lsp.util.make_range_params()
        params.context = { only = { "source.organizeImports" } }
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
        for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if r.edit then
                    vim.lsp.util.apply_workspace_edit(r.edit, "utf-16")
                else
                    vim.lsp.buf.execute_command(r.command)
                end
            end
        end
    end,
})

-- Shortcut
local keymap = vim.keymap
keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "跳到定義" })
keymap.set("n", "gr", vim.lsp.buf.references, { desc = "LSP: [G]oto [R]eferences" })
keymap.set("n", "K", vim.lsp.buf.hover, { desc = "顯示文檔" })
keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "重命名" })
keymap.set("n", "se", vim.diagnostic.open_float, { desc = "顯示錯誤" })
