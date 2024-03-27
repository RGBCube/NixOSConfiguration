lib: {
  merge = lib.mkMerge [] // {
    __functor = self: next: self // {
      contents = self.contents ++ [ next ];
    };
  };
}
