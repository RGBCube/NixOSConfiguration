{ lib, ... }: with lib; imports [

(systemConfiguration {
  console.keyMap = "trq";

  i18n.defaultLocale = "C.UTF-8";
})

(desktopSystemConfiguration {
  i18n.extraLocaleSettings = genAttrs [
    "LC_ADDRESS"
    "LC_IDENTIFICATION"
    "LC_MEASUREMENT"
    "LC_MONETARY"
    "LC_NAME"
    "LC_NUMERIC"
    "LC_PAPER"
    "LC_TELEPHONE"
    "LC_TIME"
  ] (_: "tr_TR.UTF-8");
})

]
