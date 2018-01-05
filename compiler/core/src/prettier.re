module Doc = {
  type t('a) = {.. "type": string} as 'a;
  module Builders = {
    let s = (s: string) : t('a) => {"type": "concat", "parts": [|s|]};
    [@bs.val] [@bs.module "prettier"] [@bs.scope ("doc", "builders")]
    external _concat : array(t('a)) => Js.t({..}) =
      "concat";
    let concat = (items) => _concat(Array.of_list(items));
    [@bs.val] [@bs.module "prettier"] [@bs.scope ("doc", "builders")]
    external _fill : array(t('a)) => Js.t({..}) =
      "fill";
    let fill = (items) => _fill(Array.of_list(items));
    [@bs.val] [@bs.module "prettier"] [@bs.scope ("doc", "builders")]
    external _join : (t('a), array(t('b))) => Js.t({..}) =
      "join";
    let join = (seperator, items) => _join(seperator, Array.of_list(items));
    [@bs.val] [@bs.module "prettier"] [@bs.scope ("doc", "builders")]
    external indent : t('a) => Js.t({..}) =
      "";
    [@bs.val] [@bs.module "prettier"] [@bs.scope ("doc", "builders")]
    external group : t('a) => Js.t({..}) =
      "";
    [@bs.val] [@bs.module "prettier"] [@bs.scope ("doc", "builders")]
    external lineSuffix : t('a) => Js.t({..}) =
      "";
    [@bs.val] [@bs.module "prettier"] [@bs.scope ("doc", "builders")]
    external ifBreak : (t('a), t('b)) => Js.t({..}) =
      "";
    [@bs.val] [@bs.module "prettier"] [@bs.scope ("doc", "builders")] external line : Js.t({..}) =
      "";
    [@bs.val] [@bs.module "prettier"] [@bs.scope ("doc", "builders")]
    external hardline : Js.t({..}) =
      "";
    [@bs.val] [@bs.module "prettier"] [@bs.scope ("doc", "builders")]
    external softline : Js.t({..}) =
      "";
    [@bs.val] [@bs.module "prettier"] [@bs.scope ("doc", "builders")]
    external lineSuffixBoundary : Js.t({..}) =
      "";
  };
  module Printer = {
    [@bs.val] [@bs.module "prettier"] [@bs.scope ("doc", "printer")]
    external printDocToString : (Js.t('a), {.. "printWidth": int}) => {.. "formatted": string} =
      "";
  };
};

[@bs.val] [@bs.module "prettier"] external format : string => string = "";