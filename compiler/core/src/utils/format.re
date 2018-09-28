[@bs.module] external camelCase: string => string = "lodash.camelcase";

[@bs.module] external upperFirst: string => string = "lodash.upperfirst";

let safeVariableName = (name: string): string =>
  name
  |> Js.String.replaceByRe([%re "/ /g"], "")
  |> Js.String.replaceByRe([%re "/-/g"], "_");

let joinWith = (separator: string, list: list(string)) =>
  switch (list) {
  | [] => ""
  | [x, ...xs] => xs |> List.fold_left((a, b) => a ++ separator ++ b, x)
  };