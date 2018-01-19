let indentLine = (amount, line) => Js.String.repeat(amount, " ") ++ line;

let rec flatMap = (f, list) =>
  switch list {
  | [head, ...tail] =>
    switch head {
    | Some(a) => [a, ...flatMap(f, tail)]
    | None => []
    }
  | [] => []
  };

module String = {
  let join = (sep, items) => items |> Array.of_list |> Js.Array.joinWith(sep);
};

let prefixAll = (sep, items) =>
  Prettier.Doc.Builders.(items |> List.map((x) => sep <+> x) |> concat);

let renderOptional = (render, item) =>
  switch item {
  | None => Prettier.Doc.Builders.empty
  | Some(a) => render(a)
  };