class t (prefix: string) = {
  as self;
  val mutable currentIndex: int = 0;
  val mutable prefix: string = prefix;
  pub next = (): string => {
    currentIndex = currentIndex + 1;
    let name = Js.Int.toStringWithRadix(currentIndex, ~radix=36);
    prefix ++ name;
  };
};