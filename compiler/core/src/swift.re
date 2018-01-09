module Format = {
  [@bs.module] external camelCase : string => string = "lodash.camelcase";
  let layerName = (layerName) => camelCase(layerName) ++ "View";
};