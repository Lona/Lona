include Map.Make({
  type t = ParameterKey.t;
  let compare = (a: ParameterKey.t, b: ParameterKey.t): int => compare(a, b);
});

let fromJsDict = dict =>
  dict
  |> Js.Dict.entries
  |> Array.fold_left(
       (map, (key, value)) =>
         add(ParameterKey.fromString(key), value, map),
       empty,
     );

let find_opt = (key, map) =>
  switch (find(key, map)) {
  | item => Some(item)
  | exception Not_found => None
  };

let assign = (base, extender) =>
  merge(
    (_, a, b) =>
      switch (a, b) {
      | (_, Some(b)) => Some(b)
      | (Some(a), None) => Some(a)
      | (None, None) => None
      },
    base,
    extender,
  );
