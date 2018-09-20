[@bs.deriving abstract]
type raw = {plugins: array(Plugin.t)};

type t = {plugins: list(Plugin.t)};

[@bs.module] external parseConfig: string => raw = "../config";

let loadConfig = (path: string) => {
  let rawConfig = parseConfig(path);
  {plugins: Array.to_list(rawConfig->plugins)};
};
