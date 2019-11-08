open Operators;

[@bs.val] [@bs.module "glob"]
external syncRaw: (string, Js.Json.t) => array(string) = "sync";

type options = {ignore: list(string)};

let sync = (glob: string, ~options: option(options)=?, ()): list(string) => {
  let jsonOptions =
    switch (options) {
    | None => Js.Json.null
    | Some(unwrapped) =>
      Json.(
        Encode.object_([
          ("ignore", Encode.stringArray(unwrapped.ignore |> Array.of_list)),
        ])
      )
    };

  let ignoreRegularExpressions =
    (options %? {ignore: []}).ignore |> List.map(Js.Re.fromString);

  let paths = syncRaw(glob, jsonOptions) |> Array.to_list;

  paths
  |> List.filter(path =>
       !(
         ignoreRegularExpressions
         |> List.exists((regularExpression: Js.Re.t) =>
              Js.Re.test(path, regularExpression)
            )
       )
     );
};