let map = (f: 'a => 'b, value: option('a)): option('b) =>
  switch (value) {
  | Some(wrapped) => Some(f(wrapped))
  | None => None
  };

let bind = (f: 'a => option('b), value: option('a)): option('b) =>
  switch (value) {
  | None => None
  | Some(a) => f(a)
  };

let default = (defaultValue: 'b, value: option('a)) =>
  switch (value) {
  | Some(wrapped) => wrapped
  | None => defaultValue
  };

let (|?) = (x, y) => default(y, x);