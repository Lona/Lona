[@bs.val] [@bs.module "glob"]
external syncRaw: (string, Js.Json.t) => array(string) = "sync";

type options = {ignore: list(string)};

let sync = (glob: string, ~options: option(options)=?, ()): list(string) => {
  let jsonOptions =
    switch (options) {
    | None => Js.Json.null
    | Some(unwrapped) =>
      let dict =
        Js.Dict.fromList([
          ("ignore", Js.Json.stringArray(unwrapped.ignore |> Array.of_list)),
        ]);
      Js.Json.object_(dict);
    };

  syncRaw(glob, jsonOptions) |> Array.to_list;
};