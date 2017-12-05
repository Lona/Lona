include
  Map.Make(
    {
      type t = string;
      let compare = (a: string, b: string) : int => compare(a, b);
    }
  );

let fromList = (list) => List.fold_left((map, (key, value)) => add(key, value, map), empty, list);

let fromJsDict = (dict) =>
  dict |> Js.Dict.entries |> Js.Array.reduce((map, (key, value)) => add(key, value, map), empty);

let assign = (base, extender) =>
  merge(
    (_, a, b) =>
      switch (a, b) {
      | (_, Some(b)) => Some(b)
      | (Some(a), None) => Some(a)
      | (None, None) => None
      },
    base,
    extender
  );