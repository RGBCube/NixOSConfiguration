lib: {
  parseDomain = url: lib.head (lib.strings.match "https?://(.*)/" url);
}
