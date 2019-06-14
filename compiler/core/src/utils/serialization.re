[@bs.val] [@bs.module "@lona/serialization"]
external convertLogic: (string, string) => string = "";

[@bs.val] [@bs.module "@lona/serialization"]
external convertTypes: (string, string) => string = "";

let convert = (contents: string, kind: string, encoding: string) =>
  switch (kind) {
  | "logic" => convertLogic(contents, encoding)
  | "types" => convertTypes(contents, encoding)
  | _ =>
    Js.log("Unknown conversion kind: " ++ kind);
    raise(Not_found);
  };