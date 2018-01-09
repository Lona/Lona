module Format = {
  [@bs.module] external camelCase : string => string = "lodash.camelcase";
  let layerName = (layerName) => camelCase(layerName) ++ "View";
};

module Document = {
  open Ast.Swift;
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
};