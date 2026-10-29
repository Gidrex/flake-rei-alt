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
          body = "mkdir -p -- \$argv; and z \$argv[-1]";
        };
        e.body = "set -q EDITOR; or set -l EDITOR hx; \$EDITOR \$argv";
        hmr.body = builtins.readFile ./hmr_function.fish;
        hm.body = "\$HOME/flake-rei/scripts/hm.sh \$argv";
        # Loads agent provider keys from sops on demand (pi !cat apiKey).
        # Run `aikeys` before a pi session.
        aikeys.body = ''set -gx OPENCODE_API_KEY (cat "${config.sops.secrets.opencode_api_key.path}"); set -gx OPENROUTER_API_KEY (cat "${config.sops.secrets.openrouter_api_key.path}"); and echo "agent keys loaded"'';
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
          test -n "$selection"; and ${pkgs.helix}/bin/hx "$selection"
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

      # herdr, mirrors the old zellij set (zl/zln/zla/zlk, see 8f664ec).
      {
        hd = {
          wraps = "herdr";
          body = "herdr $argv";
        };
        hdn = {
          wraps = "herdr";
          body = "herdr --session $argv";
        };
      }

      (lib.mkIf config.programs.skim.enable {
        __hd_pick.body = "herdr session list | tail -n +2 | awk '{print $1}' | ${pkgs.skim}/bin/sk";
        hda.body = "herdr session attach (__hd_pick)";
        hdk.body = "herdr session stop (__hd_pick)";
      })
    ];

    interactiveShellInit = ''
      set -g fish_greeting ""
      set -g fish_key_bindings fish_hybrid_key_bindings

      ${lib.optionalString (config.programs.zoxide.enable && config.programs.television.enable)
        "bind -M insert \\ez 'commandline -f cancel; z $(${config.programs.television.package}/bin/tv --source-command \"${pkgs.zoxide}/bin/zoxide query -l\" --preview-command \"${pkgs.eza}/bin/eza -la --color=always --icons=always --group-directories-first \\\"{}\\\"\" --preview-size 60 --layout landscape); commandline -f repaint'"
      }
      ${lib.optionalString config.programs.zoxide.enable "bind -M insert \\et 'commandline -f cancel; z ..; commandline -f repaint'"}
      ${lib.optionalString config.programs.helix.enable "bind -M insert \\ee 'commandline -f cancel; helixing; commandline -f repaint'"}
      ${lib.optionalString config.programs.yazi.enable "bind -M insert \\ey 'commandline -f cancel; ${pkgs.yazi}/bin/yazi; commandline -f repaint'"}
      ${lib.optionalString config.programs.lazygit.enable "bind -M insert \\ex 'commandline -f cancel; ${pkgs.lazygit}/bin/lazygit; commandline -f repaint'"}
      bind -M insert \ea 'commandline -f cancel; opencode --continue; commandline -f repaint'

      command -q tuna; and tuna completion fish | source
      command -q chora; and chora completion fish | source
    '';

    # No loginShellInit: one-time setup (e.g. `tide configure`) runs by hand,
    # never on every login (it would overwrite the user's prompt config).

    completions = {
      hmr = "complete -f -c hmr";
      # Handwritten flat style, edit by hand; checked in to avoid IFD (runCommand would rebuild on every eval).
      rip = builtins.readFile ./completions_rip.fish;
      # Handwritten: `opencode completion` emits bash-only yargs (complete -F), unusable in fish.
      opencode = builtins.readFile ./completions_opencode.fish;
    };
  };

  catppuccin.fish.enable = true;

  programs = {
    zoxide.enableFishIntegration = true;
    yazi.enableFishIntegration = true;
    eza.enableFishIntegration = false;
  };
}
