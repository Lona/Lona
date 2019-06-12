[@bs.module] external camelCase: string => string = "lodash.camelcase";

[@bs.module] external upperFirst: string => string = "lodash.upperfirst";

[@bs.module] external lowerFirst: string => string = "lodash.lowerfirst";

[@bs.module] external snakeCase: string => string = "lodash.snakecase";

let safeVariableName = (name: string): string =>
  name
  |> Js.String.replaceByRe([%re "/ /g"], "")
  |> Js.String.replaceByRe([%re "/-/g"], "_");

let joinWith = (separator: string, list: list(string)) =>
  switch (list) {
  | [] => ""
  | [x, ...xs] => xs |> List.fold_left((a, b) => a ++ separator ++ b, x)
  };

let floatToString = (float: float): string => {
  let string = string_of_float(float);

  string |> Js.String.endsWith(".") ?
    string |> Js.String.slice(~from=0, ~to_=-1) : string;
};

let vectorClassName = (assetUrl: string, elementName: option(string)): string => {
  let baseName = Node.Path.basename_ext(assetUrl, ".svg");
  let formattedName =
    (
      switch (elementName) {
      | Some(elementName) =>
        camelCase(safeVariableName(elementName))
        ++ upperFirst(camelCase(baseName))
      | None => camelCase(baseName)
      }
    )
    |> upperFirst;
  formattedName ++ "Vector";
};

let indent = (spacesCount: int, string: string) =>
  string
  |> Js.String.split("\n")
  |> Array.to_list
  |> List.map(line => Js.String.repeat(spacesCount, " ") ++ line)
  |> joinWith("\n");