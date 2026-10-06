{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.fish = {
    enable = true;
    shellAliases = lib.mkForce { };

    plugins =
      with pkgs.fishPlugins;
      map
        (plugin: {
          name = plugin.pname;
          src = plugin.src;
        })
        [
          tide
          colored-man-pages
        ];

    # Plain functions take `$argv`; `wraps` gives completions.
    functions = lib.mkMerge [
      {
        md = {
          wraps = "mkdir";
          body = "mkdir -p -- \$argv[1]; and z ./\$argv[1]";
        };
        e.body = "$EDITOR $argv";
        hmr.body = builtins.readFile ./hmr_function.fish;
        hm.body = "~/flake-rei/scripts/hm.sh $argv";
      }

      (lib.mkIf config.programs.eza.enable {
        ls = {
          wraps = "eza";
          body = "__eza_cols $argv";
        };
        la = {
          wraps = "eza";
          body = "__eza_cols -al $argv";
        };
        lt = {
          wraps = "eza";
          body = "__eza_cols -T $argv";
        };
        __eza_cols.body = "if contains -- -T \$argv; or contains -- --tree \$argv; or test (count \$argv) -gt 1; ${pkgs.eza}/bin/eza --icons=always \$argv; else; CLICOLOR_FORCE=1 paste (${pkgs.eza}/bin/eza --only-dirs -1 --color=always --icons=always \$argv | psub) (${pkgs.eza}/bin/eza --only-files -1 --color=always --icons=always \$argv | psub) | column -t -s \\t; end";
      })

      (lib.mkIf config.programs.helix.enable {
        h = {
          wraps = "hx";
          body = "${pkgs.helix}/bin/hx $argv";
        };
        # NOTE: old mapper never appended `$argv`; body reproduced verbatim (byte-identical).
        helixing = lib.mkIf (config.programs.fd.enable && config.programs.skim.enable) ''
          set -l selection (${pkgs.fd}/bin/fd . --type file --type symlink -E '*.{png,jpg,jpeg,webp,docx,svg,pdf}' | ${pkgs.skim}/bin/sk --height=20 --layout=reverse -0 -1)
          ${pkgs.helix}/bin/hx "$selection" || echo ""
        '';
      })

      (lib.mkIf config.programs.nixvim.enable {
        # nixvim itself is enabled via programs.nixvim-rei (nixvim-rei input).
        # NOTE: vanilla ${pkgs.neovim} must NOT be used here: it reads the
        # nixvim-generated init.lua without the pack-dir on rtp, so
        # require("lz.n") fails with E5113. build.package is the wrapper
        # that sets packpath/rtp via --cmd.
        n = {
          wraps = "nvim";
          body = "${config.programs.nixvim.build.package}/bin/nvim $argv";
        };
        nv = {
          wraps = "nvim";
          body = "${config.programs.nixvim.build.package}/bin/nvim $argv";
        };
      })

      # `..` == `cd ..`, `...` == `cd ../..`, and so on.
      {
        ".." = {
          wraps = "cd";
          body = "cd ..";
        };
        "..." = {
          wraps = "cd";
          body = "cd ../..";
        };
        "...." = {
          wraps = "cd";
          body = "cd ../../..";
        };
        "....." = {
          wraps = "cd";
          body = "cd ../../../..";
        };
        "......" = {
          wraps = "cd";
          body = "cd ../../../../..";
        };
      }
    ];

    interactiveShellInit = ''
      set -g fish_greeting ""
      set -g fish_key_bindings fish_hybrid_key_bindings

      ${lib.optionalString config.programs.zoxide.enable "bind -M insert \\ez 'commandline -f cancel; z $(${pkgs.zoxide}/bin/zoxide query -l | ${pkgs.skim}/bin/sk --height=20 --layout=reverse); commandline -f repaint'"}
      ${lib.optionalString config.programs.zoxide.enable "bind -M insert \\et 'commandline -f cancel; z ..; commandline -f repaint'"}
      ${lib.optionalString config.programs.helix.enable "bind -M insert \\ee 'commandline -f cancel; helixing; commandline -f repaint'"}
      ${lib.optionalString config.programs.yazi.enable "bind -M insert \\ey 'commandline -f cancel; ${pkgs.yazi}/bin/yazi; commandline -f repaint'"}
      ${lib.optionalString config.programs.lazygit.enable "bind -M insert \\ex 'commandline -f cancel; ${pkgs.lazygit}/bin/lazygit; commandline -f repaint'"}
      bind -M insert \ea 'commandline -f cancel; agy --dangerously-skip-permissions; commandline -f repaint'

      tuna completion fish | source
    '';

    loginShellInit = "tide configure --auto --style=Classic --prompt_colors='16 colors' --show_time=No --classic_prompt_separators=Round --powerline_prompt_heads=Round --powerline_prompt_tails=Round --powerline_prompt_style='Two lines, character' --prompt_connection=Dotted --powerline_right_prompt_frame=No --prompt_spacing=Sparse --icons='Many icons' --transient=Yes";

    completions = {
      hmr = "complete -f -c hmr";
      # Checked in to avoid IFD; runCommand would rebuild on every eval.
      rip = builtins.readFile ./completions_rip.fish;
    };
  };

  catppuccin.fish.enable = true;

  programs = {
    zoxide.enableFishIntegration = true;
    yazi.enableFishIntegration = true;
    eza.enableFishIntegration = false;
  };
}
