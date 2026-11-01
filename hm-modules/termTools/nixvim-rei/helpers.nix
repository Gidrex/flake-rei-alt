# Shared builders, plain import (not a home-manager module).
{ pkgs }:
{
  codelldbPath = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";

  # Snacks entries double as lz.n triggers. Callback must be a function
  # expression: lz.n evaluates the spec table at startup.
  snacksKey = key: callback: desc: {
    __unkeyed-1 = key;
    __unkeyed-2.__raw = callback;
    inherit desc;
    mode = "n";
  };

  # q quits Diffview (upstream has no q in view/panels).
  diffviewQuit = {
    mode = "n";
    key = "q";
    action.__raw = "require('diffview.actions').close";
    description = "Close Diffview";
  };

  mkN = key: action: desc: {
    mode = "n";
    inherit key action;
    options = {
      silent = true;
      inherit desc;
    };
  };
}
