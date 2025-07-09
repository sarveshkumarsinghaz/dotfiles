return {
  "stevearc/oil.nvim",
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    {
      "<leader>z",
      function()
        -- Store current directory before changing
        vim.g.previous_dir = vim.fn.getcwd()

        vim.ui.input({
          prompt = "Change to directory (zoxide): ",
          default = "",
          completion = "dir",
        }, function(input)
          if input then
            -- Try zoxide first, then fallback to regular path
            local commands = {
              "zoxide query " .. vim.fn.shellescape(input),
              "zoxide query --interactive",
            }

            for _, cmd in ipairs(commands) do
              local result = vim.fn.system(cmd)
              if vim.v.shell_error == 0 and result and result ~= "" then
                local selected_dir = result:gsub("\n", "")
                vim.cmd("cd " .. selected_dir)
                print("Changed to: " .. selected_dir)
                return
              end
            end

            -- Final fallback to regular directory
            local expanded = vim.fn.expand(input)
            if vim.fn.isdirectory(expanded) == 1 then
              vim.cmd("cd " .. expanded)
              print("Changed to: " .. expanded)
            else
              print("Directory not found: " .. input)
            end
          end
        end)
      end,
      desc = "Change directory with zoxide",
    },
  },
  config = function()
    require("oil").setup()
  end,
}
