-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Esc then j/k typed fast arrives as <A-j>/<A-k> and moves lines; drop LazyVim's mappings
for _, key in ipairs({ "<A-j>", "<A-k>" }) do
  pcall(vim.keymap.del, { "n", "i", "v" }, key)
end
