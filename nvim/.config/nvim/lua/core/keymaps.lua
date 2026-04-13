local keymap = vim.keymap

-- General
keymap.set("", "<Space>", "<Nop>", { silent = true })
keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "退回 Normal 模試" })
