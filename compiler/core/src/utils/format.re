[@bs.module] external camelCase: string => string = "lodash.camelcase";

[@bs.module] external upperFirst: string => string = "lodash.upperfirst";

let safeVariableName = (name: string): string =>
  name
  |> Js.String.replaceByRe([%re "/ /g"], "")
  |> Js.String.replaceByRe([%re "/-/g"], "_");