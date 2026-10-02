# Neovim via NixVim (no LazyVim): every plugin/LSP/binary comes from nixpkgs.
# Heavy plugins lazy-load through lz.n (keys/cmd/ft/event triggers); core stays eager.
# Lua lives in ./lua/*.lua (extraFiles + extra.lua); default.nix stays declarative.
{
  pkgs,
  config,
  inputs,
  ...
}:
let
  codelldbPath = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";

  # Snacks picker entries double as lz.n triggers: first press loads, then runs.
  snacksKey = key: callback: desc: {
    __unkeyed-1 = key;
    __unkeyed-2.__raw = callback;
    inherit desc;
    mode = "n";
  };
in
{
  catppuccin.nvim.enable = false;

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    # nixvim.inputs.nixpkgs follows nixpkgs in flake.nix by design;
    # pin the source explicitly to silence the follows warning.
    nixpkgs.source = inputs.nixpkgs;

    globals = {
      mapleader = " ";
      # sops secret path only (the value never lands in the store)
      minuet_api_key_file = config.sops.secrets.opencode_api_key.path;
      codelldb_path = codelldbPath;
      # Unused language providers (all plugins are Lua; skip their startup cost)
      loaded_node_provider = 0;
      loaded_perl_provider = 0;
      loaded_python3_provider = 0;
      loaded_ruby_provider = 0;
    };

    opts = {
      number = true;
      relativenumber = true;
      cursorline = true;
      mouse = "";
      termguicolors = true;
      wrap = true;
      linebreak = true;
      breakindent = true;
      laststatus = 3;
      shada = "!,'100,<50,s10,h";
      fixendofline = false; # do not insert final newline
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;
      expandtab = true;
      scrolloff = 5; # keep 5 lines of context above/below the cursor
      updatetime = 250;
      timeoutlen = 300;
      guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175";
    };

    colorscheme = "catppuccin";
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        compile.enabled = false;
      };
    };

    diagnostic.settings = {
      virtual_text = true;
      signs = true;
      underline = true;
      update_in_insert = false;
      severity_sort = true;
    };

    keymaps =
      let
        mkN = key: action: desc: {
          mode = "n";
          inherit key action;
          options = {
            silent = true;
            inherit desc;
          };
        };
      in
      [
        (mkN "<A-w>" ":w<CR>" "Save")
        (mkN "<A-q>" ":q<CR>" "Quit")
        # Z opens LazyGit; factory ZZ/ZQ are disabled.
        (mkN "ZZ" "<nop>" "Disabled")
        (mkN "ZQ" "<nop>" "Disabled")
        {
          mode = "n";
          key = "Z";
          action.__raw = "require('helpers').open_lazygit";
          options = {
            silent = true;
            desc = "LazyGit";
          };
        }
        # Hunk navigation (diff mode falls back to builtin [c/]c, see lua/hunks.lua)
        {
          mode = "n";
          key = "]c";
          action.__raw = "require('hunks').next";
          options.desc = "Next hunk";
        }
        {
          mode = "n";
          key = "[c";
          action.__raw = "require('hunks').prev";
          options.desc = "Prev hunk";
        }
        # Yazi picker (yazi with a chooser file); <C-y> stays a Vim default.
        {
          mode = "n";
          key = "<leader>y";
          action.__raw = "require('helpers').open_yazi_picker";
          options = {
            silent = true;
            desc = "Yazi Picker";
          };
        }
        # Minuet: manual AI completion trigger (auto runs via blink source, see lua/minuet-setup.lua)
        {
          mode = "i";
          key = "<A-y>";
          action.__raw = "require('minuet-setup').show";
          options.desc = "Minuet: complete manually";
        }
        # DAP controls
        {
          mode = "n";
          key = "<F5>";
          action.__raw = "function() require('dap').continue() end";
          options.desc = "DAP: continue";
        }
        {
          mode = "n";
          key = "<F10>";
          action.__raw = "function() require('dap').step_over() end";
          options.desc = "DAP: step over";
        }
        {
          mode = "n";
          key = "<F11>";
          action.__raw = "function() require('dap').step_into() end";
          options.desc = "DAP: step into";
        }
        {
          mode = "n";
          key = "<F12>";
          action.__raw = "function() require('dap').step_out() end";
          options.desc = "DAP: step out";
        }
        # Flat space binds (no subgroups except Git review + Debug)
        (mkN "<leader>q" ":!qalc -s 'maxdeci 2' -t -f /dev/stdin<CR>" "Calculator")
        (mkN "<leader><leader>" ":e!<CR>" "Reload Buffer")
        {
          mode = "n";
          key = "<leader>c";
          action.__raw = "vim.lsp.buf.code_action";
          options.desc = "Code Action";
        }
        {
          mode = "n";
          key = "<leader>r";
          action.__raw = "vim.lsp.buf.rename";
          options.desc = "Rename";
        }
        {
          mode = "n";
          key = "<leader>D";
          action.__raw = "vim.lsp.buf.definition";
          options.desc = "Go to Definition";
        }
        {
          mode = "n";
          key = "<leader>h";
          action.__raw = "vim.lsp.buf.hover";
          options.desc = "Hover";
        }
        {
          mode = "n";
          key = "<leader>i";
          action.__raw = "require('helpers').toggle_inlay_hints";
          options.desc = "Toggle Inlay Hints";
        }
        {
          mode = "n";
          key = "<leader>G";
          action = "<nop>";
          options.desc = "+Git review";
        }
        (mkN "<leader>Gs" "<cmd>Gitsigns stage_hunk<CR>" "Stage Hunk")
        (mkN "<leader>Gr" "<cmd>Gitsigns reset_hunk<CR>" "Reset Hunk")
        (mkN "<leader>Gp" "<cmd>Gitsigns preview_hunk<CR>" "Preview Hunk")
        (mkN "<leader>Gb" "<cmd>Gitsigns blame_line<CR>" "Blame Line")
        (mkN "<leader>Gd" "<cmd>Gitsigns diffthis<CR>" "Diff This")
        (mkN "<leader>GD" "<cmd>DiffviewOpen<CR>" "Side-by-side Diff")
        (mkN "<leader>Gl" "<cmd>DiffviewFileHistory<CR>" "File History")
        {
          mode = "n";
          key = "<leader>B";
          action = "<nop>";
          options.desc = "+Debug (DAP)";
        }
        {
          mode = "n";
          key = "<leader>Bb";
          action.__raw = "function() require('dap').toggle_breakpoint() end";
          options.desc = "Toggle Breakpoint";
        }
        {
          mode = "n";
          key = "<leader>Bc";
          action.__raw = "function() require('dap').set_breakpoint(vim.fn.input('Condition: ')) end";
          options.desc = "Conditional Breakpoint";
        }
        {
          mode = "n";
          key = "<leader>Br";
          action.__raw = "function() require('dap').repl.toggle() end";
          options.desc = "REPL";
        }
        {
          mode = "n";
          key = "<leader>Bu";
          action.__raw = "function() require('dapui').toggle() end";
          options.desc = "UI";
        }
        {
          mode = "n";
          key = "<leader>Bt";
          action.__raw = "function() require('dap').terminate() end";
          options.desc = "Terminate";
        }
      ];

    autoCmd = [
      # Do not auto-continue comments (ftplugins reset formatoptions, so re-apply)
      {
        event = "FileType";
        pattern = "*";
        callback.__raw = "require('autocmds').no_comment_continue";
      }
      # Conventional-commit friendly: spell + 72-col wrap in gitcommit buffers
      {
        event = "FileType";
        pattern = "gitcommit";
        callback.__raw = "require('autocmds').gitcommit_opts";
      }
      # Show inlay hints when the server provides them
      {
        event = "LspAttach";
        callback.__raw = "require('autocmds').maybe_enable_inlay_hints";
      }
    ];

    plugins = {
      lz-n.enable = true;

      lualine = {
        enable = true;
        settings = {
          options = {
            theme = "auto";
            component_separators = "│";
            section_separators = "";
            globalstatus = true;
          };
          sections = {
            lualine_a = [
              {
                __unkeyed-1 = "mode";
                fmt.__raw = "function(str) return str:upper() end";
              }
            ];
            lualine_b = [
              "branch"
              "filetype"
            ];
            lualine_c = [ "filename" ];
            lualine_x = [ "diagnostics" ];
            lualine_y = [
              "selectioncount"
              "progress"
            ];
            lualine_z = [
              "location"
              "encoding"
            ];
          };
        };
      };

      gitsigns.enable = true;
      which-key.enable = true;
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };
      diffview = {
        enable = true;
        lazyLoad.settings.cmd = [
          "DiffviewOpen"
          "DiffviewFileHistory"
        ];
      };
      trouble = {
        enable = true;
        lazyLoad.settings.cmd = "Trouble";
      };
      aerial = {
        enable = true;
        lazyLoad.settings.keys = [
          (snacksKey "<leader>a" "function() require('aerial').toggle() end" "Outline (Aerial)")
        ];
      };
      snacks = {
        enable = true;
        settings.picker.enabled = true;
        lazyLoad.settings.keys = [
          (snacksKey "<leader>f" "function() Snacks.picker.files() end" "File Picker")
          (snacksKey "<leader>b" "function() Snacks.picker.buffers() end" "Buffers")
          (snacksKey "<leader>g" "function() Snacks.picker.git_status() end" "Git Status (Diff)")
          (snacksKey "<leader>/" "function() Snacks.picker.grep() end" "Live Grep")
          (snacksKey "<leader>d" "function() Snacks.picker.diagnostics() end" "Diagnostics")
        ];
      };
      render-markdown = {
        enable = true;
        lazyLoad.settings.ft = "markdown";
      };
      indent-blankline = {
        enable = true;
        settings = {
          indent.char = "▏";
          scope.enabled = false;
        };
      };
      mini = {
        enable = true;
        modules = {
          pairs = { };
          ai = { };
          comment = {
            mappings = {
              comment = "gc";
              textobject = "gc";
            };
          };
          surround = {
            mappings = {
              add = "ms";
              delete = "md";
              replace = "mr";
            };
          };
        };
      };

      blink-cmp = {
        enable = true;
        settings = {
          keymap.preset = "default";
          appearance = {
            use_nvim_cmp_as_default = true;
            nerd_font_variant = "mono";
          };
          sources = {
            default = [
              "lsp"
              "path"
              "snippets"
              "buffer"
              "minuet"
            ];
            providers.minuet = {
              name = "minuet";
              module = "minuet.blink";
              async = true;
              timeout_ms = 3000;
              score_offset = 50;
            };
          };
          completion.trigger.prefetch_on_insert = false;
          signature.enabled = true;
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            nix = [ "nixfmt" ];
            lua = [ "stylua" ];
            python = [ "ruff_format" ]; # 4 spaces: ruff/PEP8 standard, not 2
            rust = [ "rustfmt" ];
            javascript = [
              "deno_fmt"
              "biome"
            ];
            typescript = [
              "deno_fmt"
              "biome"
            ];
            javascriptreact = [
              "deno_fmt"
              "biome"
            ];
            typescriptreact = [
              "deno_fmt"
              "biome"
            ];
            json = [
              "deno_fmt"
              "biome"
            ];
            toml = [ "taplo" ];
            yaml = [ "yamlfmt" ];
            sh = [ "shfmt" ];
          };
          formatters = {
            nixfmt.prepend_args = [
              "--width"
              "120"
            ];
            stylua.prepend_args = [
              "--indent-type"
              "Spaces"
              "--indent-width"
              "2"
            ];
            rustfmt.prepend_args = [
              "--config"
              "tab_spaces=2"
            ];
            shfmt.prepend_args = [
              "-i"
              "2"
            ];
            # Deno projects (deno.json*) format with deno, everything else with biome (see lua/format-cond.lua)
            deno_fmt.condition.__raw = "require('format-cond').is_deno";
            biome.condition.__raw = "require('format-cond').is_not_deno";
          };
          format_on_save = {
            timeout_ms = 500;
            lsp_format = "fallback";
          };
        };
        lazyLoad.settings = {
          event = "BufWritePre";
          keys = [
            (snacksKey "<leader>F" "require('format-cond').format_buffer" "Format Buffer")
          ];
        };
      };

      dap.enable = true;
      dap-ui.enable = true;

      # NOTE: nixvim wraps settings with the server key (lua_ls -> Lua,
      # rust_analyzer -> rust-analyzer, yamlls -> yaml, ...), so set the
      # inner content only or the generated config nests it twice.
      lsp = {
        enable = true;
        servers = {
          nil_ls = {
            enable = true;
            package = null;
          };
          lua_ls = {
            enable = true;
            package = null;
            settings = {
              diagnostics.globals = [ "vim" ];
              workspace.checkThirdParty = false;
              telemetry.enabled = false;
            };
          };
          pyright = {
            enable = true;
            package = null;
          };
          ruff = {
            enable = true;
            package = null;
          };
          rust_analyzer = {
            enable = true;
            installRustc = false; # rustc/cargo come from rustup, not Nixvim
            installCargo = false;
            settings = {
              check.command = "clippy";
              cargo = {
                buildScripts.enable = true;
                features = "all";
              };
              procMacro.enable = true;
              rustfmt.rangeFormatting.enable = true;
              inlayHints = {
                bindingModeHints.enable = true;
                chainingHints.enable = true;
                closingBraceHints.enable = true;
                closureCaptureHints.enable = true;
                closureReturnTypeHints.enable = "always";
                closureStyle = "impl_fn";
                discriminantHints.enable = "always";
                expressionAdjustmentHints.enable = "always";
                implicitDrops.enable = true;
                lifetimeElisionHints = {
                  enable = "always";
                  useParameterNames = true;
                };
                parameterHints.enable = true;
                reborrowHints.enable = "always";
                typeHints.enable = true;
              };
            };
          };
          denols = {
            enable = true;
            package = null;
          };
          yamlls = {
            enable = true;
            package = null;
          };
          taplo = {
            enable = true;
            package = null;
          };
          bashls = {
            enable = true;
            package = null;
          };
          fish_lsp = {
            enable = true;
            package = null;
          };
          gopls = {
            enable = true;
            package = null;
          };
          biome = {
            enable = true;
            package = null;
          };
          html = {
            enable = true;
            package = null;
          };
          cssls = {
            enable = true;
            package = null;
          };
          jsonls = {
            enable = true;
            package = null;
          };
          dockerls = {
            enable = true;
            package = null;
          };
          helm_ls = {
            enable = true;
            package = null;
          };
          just = {
            enable = true;
            package = null;
          };
          ansiblels = {
            enable = true;
            package = null;
          };
          hyprls = {
            enable = true;
            package = null;
          };
          marksman = {
            enable = true;
            package = null;
          };
          markdown_oxide = {
            enable = true;
            package = null;
          };
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      plenary-nvim # required by gitsigns/diffview
      minuet-ai-nvim # AI completion (setup in lua/minuet-setup.lua)
      friendly-snippets
      nvim-nio # required by nvim-dap-ui
    ];

    extraPackages = with pkgs; [
      # Nix
      nil
      nixfmt

      # Lua
      lua-language-server
      stylua

      # Python
      python3
      pyright
      ruff
      ty
      python313Packages.debugpy # DAP adapter (python3 -m debugpy.adapter)

      # Rust
      rust-analyzer
      rustfmt
      vscode-extensions.vadimcn.vscode-lldb # DAP adapter (codelldb, MIT)

      # JS/TS/JSON + HTML/CSS
      deno
      biome
      vscode-langservers-extracted

      # Shell
      bash-language-server
      fish-lsp
      shfmt

      # TOML
      taplo
      tombi

      # YAML
      yaml-language-server
      yamlfmt

      # Markdown
      markdown-oxide
      marksman

      # Go
      gopls
      delve # DAP adapter (dlv dap)

      # Ops tooling
      dockerfile-language-server
      helm-ls
      just-lsp
      ansible-language-server
      hyprls

      # AI completion HTTP (minuet-ai)
      curl
    ];

    # Runtime Lua modules (see ./lua/); extra.lua wires setup modules together.
    extraFiles = {
      "lua/helpers.lua".source = ./lua/helpers.lua;
      "lua/hunks.lua".source = ./lua/hunks.lua;
      "lua/autocmds.lua".source = ./lua/autocmds.lua;
      "lua/format-cond.lua".source = ./lua/format-cond.lua;
      "lua/dap-setup.lua".source = ./lua/dap-setup.lua;
      "lua/minuet-setup.lua".source = ./lua/minuet-setup.lua;
    };

    extraConfigLua = builtins.readFile ./lua/extra.lua;

    # Keep init.lua readable: byte-compiled traces point at :0 and hide real line numbers.
    performance.byteCompileLua.enable = false;
  };
}
