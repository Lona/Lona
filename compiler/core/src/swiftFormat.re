[@bs.module] external camelCase : string => string = "lodash.camelcase";

[@bs.module] external upperFirst : string => string = "lodash.upperfirst";

let layerName = (layerName) => camelCase(layerName) ++ "View";