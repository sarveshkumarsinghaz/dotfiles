-- Enhanced C# Configuration with none-ls and csharpier
-- Save this as: ~/.config/nvim/lua/plugins/csharp.lua

return {
  -- Enhanced completion with auto-imports (loaded early)
  {
    "hrsh7th/nvim-cmp",
    enabled = true,
    event = { "InsertEnter", "BufReadPre", "BufNewFile" },
    lazy = false,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
        }, {
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
      })
    end,
  },

  -- Mason for managing LSP servers and tools
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "omnisharp", -- C# LSP server
        "csharpier", -- C# formatter
        "netcoredbg", -- .NET Core debugger
      },
    },
  },
  -- Conform.nvim for formatting (LazyVim default)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
      },
      formatters = {
        csharpier = {
          command = "dotnet",
          args = { "csharpier", "--write-stdout" },
        },
      },
    },
  },
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      lspconfig.omnisharp.setup({
        capabilities = capabilities,
        cmd = {
          "dotnet",
          vim.fn.stdpath("data") .. "/mason/packages/omnisharp/OmniSharp.dll",
        },
        settings = {
          EnableEditorConfigSupport = true,
          ["DotNet:enablePackageRestore"] = false,
          ["Sdk:IncludePrereleases"] = true,
          FormattingOptions = {
            EnableEditorConfigSupport = true,
            OrganizeImports = true,
          },
        },
        root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", "omnisharp.json"),
        -- Disable LSP formatting in favor of none-ls
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          vim.keymap.set("n", "<leader>cf", function()
            require("conform").format({ bufnr = bufnr })
          end, { buffer = bufnr, desc = "Format with csharpier" })

          -- Lightbulb for code actions
          local lightbulb_augroup = vim.api.nvim_create_augroup("csharp_lightbulb", { clear = true })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = bufnr,
            group = lightbulb_augroup,
            callback = function()
              local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1
              local diagnostics = vim.diagnostic.get(bufnr, { lnum = current_line })
              if vim.tbl_isempty(diagnostics) then
                vim.fn.sign_unplace("LspCodeAction", { buffer = bufnr })
                return
              end

              local params = vim.lsp.util.make_range_params()
              params.context = {
                diagnostics = diagnostics,
                only = {
                  "quickfix",
                  "refactor",
                  "source.organizeImports",
                  "source.removeUnnecessaryImports",
                  "source.addMissingImports",
                  "source.fixAll",
                },
              }
              vim.lsp.buf_request(bufnr, "textDocument/codeAction", params, function(err, result, _, _)
                if err or not result or vim.tbl_isempty(result) then
                  vim.fn.sign_unplace("LspCodeAction", { buffer = bufnr })
                  return
                end
                local cursor = vim.api.nvim_win_get_cursor(0)
                local line = cursor[1]
                vim.fn.sign_define("LspCodeAction", { text = "💡", texthl = "Question" })
                vim.fn.sign_place(0, "LspCodeAction", "LspCodeAction", bufnr, { lnum = line })
              end)
            end,
          })
          vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = bufnr,
            group = lightbulb_augroup,
            callback = function()
              vim.fn.sign_unplace("LspCodeAction", { buffer = bufnr })
            end,
          })
        end,
      })
    end,
  },

  -- Treesitter for C# syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c_sharp",
      },
    },
  },

  -- DAP (Debug Adapter Protocol) for debugging
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup DAP UI
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
          },
        },
      })

      -- Setup virtual text
      require("nvim-dap-virtual-text").setup()

      -- C# DAP configuration
      dap.adapters.coreclr = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
      }

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          program = function()
            -- Find .csproj file in current directory or parent directories
            local csproj_file = vim.fn.findfile("*.csproj", ".;")
            if csproj_file == "" then
              return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
            end
            -- Get project name from .csproj file
            local project_name = vim.fn.fnamemodify(csproj_file, ":t:r")
            local project_dir = vim.fn.fnamemodify(csproj_file, ":h")
            -- Look for the dll in Debug directory
            local dll_path = project_dir .. "/bin/Debug/net*/" .. project_name .. ".dll"
            local dll_files = vim.fn.glob(dll_path, false, true)
            if #dll_files > 0 then
              return dll_files[1]
            else
              -- Fallback to manual input if dll not found
              return vim.fn.input("Path to dll: ", project_dir .. "/bin/Debug/", "file")
            end
          end,
        },
        {
          type = "coreclr",
          name = "attach - netcoredbg",
          request = "attach",
          processId = function()
            return require("dap.utils").pick_process()
          end,
        },
      }

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Keymaps for debugging
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
      vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step Over" })
      vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Step Out" })
      vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle REPL" })
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run Last" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
      vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
    end,
  },

  -- Enhanced C# support with auto-imports and code actions
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    lazy = false,
    ft = "cs",
    config = function()
      local omnisharp_extended = require("omnisharp_extended")

      -- Override the default LSP keybindings for C# files
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("omnisharp_commands", { clear = true }),
        pattern = "*.cs",
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "omnisharp" then
            local buf = args.buf

            -- Enhanced go to definition
            vim.keymap.set("n", "gd", omnisharp_extended.lsp_definition, { buffer = buf, desc = "Go to Definition" })
            vim.keymap.set("n", "gr", omnisharp_extended.lsp_references, { buffer = buf, desc = "Go to References" })
            vim.keymap.set(
              "n",
              "gi",
              omnisharp_extended.lsp_implementation,
              { buffer = buf, desc = "Go to Implementation" }
            )
            vim.keymap.set(
              "n",
              "<leader>D",
              omnisharp_extended.lsp_type_definition,
              { buffer = buf, desc = "Go to Type Definition" }
            )

            -- Code actions and auto-imports
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = buf, desc = "Code Actions" })
            vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, { buffer = buf, desc = "Code Actions" })

            -- Format with csharpier via none-ls
            vim.keymap.set("n", "<leader>cf", function()
              vim.lsp.buf.format({
                filter = function(client)
                  return client.name == "conform"
                end,
              })
            end, { buffer = buf, desc = "Format with csharpier" })

            -- Fix all fixable issues
            vim.keymap.set("n", "<leader>cF", function()
              vim.lsp.buf.code_action({
                filter = function(action)
                  return action.kind and action.kind:match("source.fixAll")
                end,
                apply = true,
              })
            end, { buffer = buf, desc = "Fix All Issues" })

            -- Dotnet commands
            vim.keymap.set("n", "<leader>cb", "<cmd>!dotnet build<cr>", { buffer = buf, desc = "Build Project" })
            vim.keymap.set("n", "<leader>cr", "<cmd>!dotnet run<cr>", { buffer = buf, desc = "Run Project" })
            vim.keymap.set("n", "<leader>ct", "<cmd>!dotnet test<cr>", { buffer = buf, desc = "Run Tests" })
            vim.keymap.set("n", "<leader>cR", "<cmd>!dotnet restore<cr>", { buffer = buf, desc = "Restore Packages" })
            vim.keymap.set("n", "<leader>cc", "<cmd>!dotnet clean<cr>", { buffer = buf, desc = "Clean Project" })
          end
        end,
      })
    end,
  },

  -- Code snippets for C#
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local ls = require("luasnip")

      -- Load friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      -- Custom C# snippets
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node

      ls.add_snippets("cs", {
        s("class", {
          t("public class "),
          i(1, "ClassName"),
          t({
            "",
            "{",
            "    ",
            i(0),
            "}",
          }),
        }),
        s("interface", {
          t("public interface "),
          i(1, "IInterfaceName"),
          t({
            "",
            "{",
            "    ",
            i(0),
            "}",
          }),
        }),
        s("prop", {
          t("public "),
          i(1, "int"),
          t(" "),
          i(2, "PropertyName"),
          t(" { get; set; }"),
          i(0),
        }),
        s("method", {
          t("public "),
          i(1, "void"),
          t(" "),
          i(2, "MethodName"),
          t("("),
          i(3),
          t({
            ")",
            "{",
            "    ",
            i(0),
            "}",
          }),
        }),
      })
    end,
  },
}
