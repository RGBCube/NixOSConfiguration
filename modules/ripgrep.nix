{ lib, ... }: with lib; imports [

(systemConfiguration {
  environment.shellAliases = {
    rg   = "rg --line-number --smart-case";
    todo = ''rg "todo|fixme" --colors match:fg:yellow --colors match:style:bold'';
  };
})

(homeConfiguration {
  programs.ripgrep = enabled;
})

]
