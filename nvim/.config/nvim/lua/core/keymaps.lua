local keymap = vim.keymap

-- General
keymap.set("", "<Space>", "<Nop>", { silent = true })
keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "退回 Normal 模試" })
keymap.set("v", "<Tab>", ">gv", { desc = "增加縮排" })
keymap.set("v", "<S-Tab>", "<gv", { desc = "減少縮排" })
