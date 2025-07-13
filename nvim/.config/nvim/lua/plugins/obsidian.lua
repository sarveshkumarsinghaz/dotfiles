return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New note" },
    { "<leader>of", "<cmd>ObsidianSearch<cr>", desc = "Search notes" },
    { "<leader>ot", "<cmd>ObsidianTags<cr>", desc = "Search tags" },
    { "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Today's note" },
    { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Yesterday's note" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Backlinks" },
    { "<leader>ol", "<cmd>ObsidianLinks<cr>", desc = "Links" },
    { "<leader>or", "<cmd>ObsidianRename<cr>", desc = "Rename note" },
    { "<leader>ow", "<cmd>ObsidianWorkspace<cr>", desc = "Switch workspace" },
  },
  opts = {
    workspaces = {
      {
        name = "main",
        path = "~/Documents/Obsidian/Main/", -- Your vault path
      },
    },

    -- Use clean filenames based on title
    note_id_func = function(title)
      if title ~= nil then
        -- Convert title to clean filename
        return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- Fallback for untitled notes
        return tostring(os.time())
      end
    end,

    -- Simplified frontmatter
    note_frontmatter_func = function(note)
      return {
        tags = note.tags,
        created = os.date("%Y-%m-%d %H:%M:%S"),
      }
    end,

    -- Simple wiki links
    wiki_link_func = function(opts)
      return string.format("[[%s]]", opts.label or opts.id)
    end,

    -- Prefer wiki-style links
    preferred_link_style = "wiki",

    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },

    mappings = {
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
    },
  },
}
