-- ~/.config/nvim/lua/custom/init.lua

return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Require your existing lspconfig configurations
      require "configs.lspconfig"

      -- --- Start of OmniSharp Custom Configuration ---
      -- We explicitly define the OmniSharp setup because its default
      -- 'cmd' might not be correct for Mason installations (which use dotnet to run a DLL).
      local lspconfig = require("lspconfig")
      local capabilities = nil -- Initialize capabilities

      -- Check if 'cmp_nvim_lsp' is loaded to get default capabilities
      -- This ensures features like snippets and completion work correctly
      if pcall(require, "cmp_nvim_lsp") then
        capabilities = require("cmp_nvim_lsp").default_capabilities()
      else
        capabilities = vim.lsp.protocol.make_client_capabilities()
      end

      lspconfig.omnisharp.setup({
        capabilities = capabilities,
        -- !!! IMPORTANT: Replace this path with the actual path you found !!!
        -- Example for .net8.0:
        cmd = {
          "dotnet",
          vim.fn.stdpath("data") .. "/mason/packages/omnisharp/OmniSharp.dll" -- <<-- UPDATE THIS LINE
        },
        -- If your path was directly under omnisharp:
        -- cmd = {
        --    "dotnet",
        --    vim.fn.stdpath("data") .. "/mason/packages/omnisharp/OmniSharp.dll"
        -- },

        -- OmniSharp specific settings from your error message, adjust as needed
        settings = {
          EnableEditorConfigSupport = true,
          ["DotNet:enablePackageRestore"] = false, -- Correct Lua syntax for keys with colons
          ["Sdk:IncludePrereleases"] = true,      -- Correct Lua syntax for keys with colons
          -- Add any other OmniSharp specific settings here
        },

        -- Root directory detection for C# projects (solution files, project files)
        root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", "omnisharp.json"),

        -- Optional: Custom actions when the LSP client attaches to a buffer
        -- on_attach = function(client, bufnr)
        --   -- Example: You might set up keymaps here for LSP functions or other custom logic
        --   -- require("your_custom_mappings").on_attach(client, bufnr)
        -- end,
      })
      -- --- End of OmniSharp Custom Configuration ---
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "csharp-language-server", -- While omnisharp is primary, keeping this for completeness if needed
        "omnisharp",
        "xmlformatter",
        "stylua",
        "bicep-lsp",
        "html-lsp",
        "css-lsp",
        "csharpier",
        "prettier",
        "json-lsp"
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- ensure_installed = "all"
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "c_sharp", -- Ensure C# parser is installed for syntax highlighting
        "bicep"
      },
    },
  },
  -- ~/.config/nvim/lua/plugins/init.lua
-- ...

{
    -- Debug Framework
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      require "configs.nvim-dap"
    end,
    event = "VeryLazy",
  },
  { "nvim-neotest/nvim-nio" },
  {
    -- UI for debugging
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      require "configs.nvim-dap-ui"
    end,
  },
  {
    "nvim-neotest/neotest",
    requires = {
      {
        "Issafalcon/neotest-dotnet",
      }
    },
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter"
    }
  },
  {
    "Issafalcon/neotest-dotnet",
    lazy = false,
    dependencies = {
      "nvim-neotest/neotest"
    }
  },
}
