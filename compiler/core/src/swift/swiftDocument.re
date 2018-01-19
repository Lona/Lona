open SwiftAst;

let join = (sep, nodes) =>
  switch nodes {
  | [] => []
  | _ => nodes |> List.fold_left((acc, node) => acc @ [sep, node], [])
  };

let joinGroups = (sep, groups) => {
  let nonEmpty = groups |> List.filter((x) => List.length(x) > 0);
  switch nonEmpty {
  | [] => []
  | [hd, ...tl] => tl |> List.fold_left((acc, nodes) => acc @ [sep] @ nodes, hd)
  }
};

let lonaValue = (colors, value: Types.lonaValue) =>
  switch value.ltype {
  | Reference(typeName) =>
    switch typeName {
    | "Boolean" => LiteralExpression(Boolean(value.data |> Json.Decode.bool))
    | "Number" => LiteralExpression(FloatingPoint(value.data |> Json.Decode.float))
    | "String" => LiteralExpression(String(value.data |> Json.Decode.string))
    | _ => SwiftIdentifier("UnknownReferenceType: " ++ typeName)
    }
  | Named(alias, subtype) =>
    switch alias {
    | "Color" =>
      let rawValue = value.data |> Json.Decode.string;
      switch (Color.find(colors, rawValue)) {
      | Some(color) => MemberExpression([SwiftIdentifier("Colors"), SwiftIdentifier(color.id)])
      | None => LiteralExpression(Color(rawValue))
      }
    | _ => SwiftIdentifier("UnknownNamedTypeAlias" ++ alias)
    }
  };