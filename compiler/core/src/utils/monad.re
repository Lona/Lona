let bindOption = (f: 'a => option('b), value: option('a)): option('b) =>
  switch (value) {
  | None => None
  | Some(a) => f(a)
  };

let map = (f: 'a => 'b, value: option('a)): option('b) =>
  switch (value) {
  | None => None
  | Some(a) => Some(f(a))
  };

let (>>=) = (x, y) => bindOption(y, x);