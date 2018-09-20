include Set.Make({
  type t = string;
  let compare = (a: string, b: string): int => compare(a, b);
});

let find_opt = (name, set) =>
  switch (find(name, set)) {
  | item => Some(item)
  | exception Not_found => None
  };

let has = (name, set) =>
  switch (find_opt(name, set)) {
  | Some(_) => true
  | None => false
  };
