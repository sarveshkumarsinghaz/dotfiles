-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Custom background color override
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Set your custom background color
    local bg_color = "#0e1419"

    -- Apply to all relevant highlight groups
    local highlights = {
      "Normal",
      "NormalNC",
      "SignColumn",
      "LineNr",
      "CursorLineNr",
      "EndOfBuffer",
      "StatusLine",
      "StatusLineNC",
      "NormalFloat",
      "FloatBorder",
      "WinSeparator",
      "VertSplit",
      "TelescopeNormal",
      "TelescopeBorder",
      "TelescopePromptNormal",
      "TelescopeResultsNormal",
      "TelescopePreviewNormal",
      "NeoTreeNormal",
      "NeoTreeNormalNC",
      "NeoTreeEndOfBuffer",
      "WhichKeyFloat",
      "LazyNormal",
      "MasonNormal",
      "NotifyBackground",
      "MsgArea",
      "Pmenu",
      "PmenuSbar",
      "PmenuThumb",
      "TabLine",
      "TabLineFill",
      "TabLineSel",
      "WinBar",
      "WinBarNC",
    }

    for _, group in ipairs(highlights) do
      -- Get existing highlight group
      local hl = vim.api.nvim_get_hl(0, { name = group })
      -- Set background while preserving other attributes
      hl.bg = bg_color
      vim.api.nvim_set_hl(0, group, hl)
    end
  end,
})

-- Apply immediately if any colorscheme is already loaded
if vim.g.colors_name then
  vim.cmd("doautocmd ColorScheme")
end

-- Additional autocmd to ensure background is applied after plugins load
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      vim.cmd("doautocmd ColorScheme")
    end, 100)
  end,
})
