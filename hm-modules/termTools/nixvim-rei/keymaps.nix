{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (import ./helpers.nix { inherit pkgs; }) mkN;
  cfg = config.programs.nixvim-rei;
in
{
  config = lib.mkIf cfg.enable {
    programs.nixvim.keymaps = [
      (mkN "<A-w>" ":w<CR>" "Save")
      (mkN "<A-q>" ":q<CR>" "Quit")
      # ZZ/ZQ disabled.
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
      # Diff mode falls back to builtin [c/]c (lua/hunks.lua).
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
      {
        mode = "n";
        key = "]g";
        action.__raw = "require('hunks').next";
        options.desc = "Next Change";
      }
      {
        mode = "n";
        key = "[g";
        action.__raw = "require('hunks').prev";
        options.desc = "Prev Change";
      }
      {
        mode = "n";
        key = "]G";
        action.__raw = "require('hunks').last";
        options.desc = "Last Change";
      }
      {
        mode = "n";
        key = "[G";
        action.__raw = "require('hunks').first";
        options.desc = "First Change";
      }
      # m is a Match group (Vim marks m{a-z} are overridden by design).
      {
        mode = "n";
        key = "m";
        action = "<nop>";
        options = {
          silent = true;
          desc = "+Match";
        };
      }
      {
        mode = "v";
        key = "m";
        action = "<nop>";
        options = {
          silent = true;
          desc = "+Match";
        };
      }
      # mm jumps to the matching bracket (builtin %, kept working after % is rebound below).
      (mkN "mm" "%" "Goto matching bracket")
      {
        mode = "v";
        key = "mm";
        action = "%";
        options = {
          silent = true;
          desc = "Goto matching bracket";
        };
      }
      # ma/mi select around/inside via mini.ai (remap so enhanced a/i objects apply).
      {
        mode = "n";
        key = "ma";
        action = "va";
        options = {
          silent = true;
          remap = true;
          desc = "Select around object";
        };
      }
      {
        mode = "n";
        key = "mi";
        action = "vi";
        options = {
          silent = true;
          remap = true;
          desc = "Select inside object";
        };
      }
      {
        mode = "v";
        key = "ma";
        action = "a";
        options = {
          silent = true;
          remap = true;
          desc = "Select around object";
        };
      }
      {
        mode = "v";
        key = "mi";
        action = "i";
        options = {
          silent = true;
          remap = true;
          desc = "Select inside object";
        };
      }
      {
        mode = "o";
        key = "ma";
        action = "a";
        options = {
          silent = true;
          remap = true;
          desc = "Around object";
        };
      }
      {
        mode = "o";
        key = "mi";
        action = "i";
        options = {
          silent = true;
          remap = true;
          desc = "Inside object";
        };
      }
      # % selects the whole file (operator-pending % keeps builtin matching, so d% still works).
      (mkN "%" "ggVG" "Select whole file")
      {
        mode = "v";
        key = "%";
        action = "<Esc>ggVG";
        options = {
          silent = true;
          desc = "Select whole file";
        };
      }
      # Visual s prompts for a regex and selects its matches (all highlighted via /).
      {
        mode = "v";
        key = "s";
        action = "<Esc><cmd>lua require('helpers').select_regex()<CR>";
        options = {
          silent = true;
          desc = "Select regex matches";
        };
      }
      # gh overrides Vim-default select mode.
      (mkN "gh" "0" "First Character of Line")
      (mkN "gl" "$" "Last Character of Line")
      {
        mode = "v";
        key = "gh";
        action = "0";
        options = {
          silent = true;
          desc = "First Character of Line";
        };
      }
      {
        mode = "v";
        key = "gl";
        action = "$";
        options = {
          silent = true;
          desc = "Last Character of Line";
        };
      }
      # <C-y> overrides Vim-default scroll-up.
      {
        mode = "n";
        key = "<C-y>";
        action.__raw = "require('helpers').open_yazi_picker";
        options = {
          silent = true;
          desc = "Yazi Picker";
        };
      }
      {
        mode = "v";
        key = "<leader>y";
        action = "\"+y";
        options.desc = "Yank Selection to System Clipboard";
      }
      (mkN "<leader>p" "\"+p" "Paste from System Clipboard")
      # Manual menu: Tab shows the full menu.
      {
        mode = "i";
        key = "<A-;>";
        action = "<C-o>:";
        options.desc = "Command mode from insert";
      }
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
  };
}
