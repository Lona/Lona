let bindOption = (f: 'a => option('b), value: option('a)): option('b) =>
  switch (value) {
  | None => None
  | Some(a) => f(a)
  };

let (>>=) = (x, y) => x |> (y |> bindOption);