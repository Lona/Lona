open SwiftAst;

let join = (sep, nodes) =>
  switch nodes {
  | [] => []
  | _ => nodes |> List.fold_left((acc, node) => acc @ [sep, node], [])
  };

let joinGroups = (sep, groups) => {
  let nonEmpty = groups |> List.filter(x => List.length(x) > 0);
  switch nonEmpty {
  | [] => []
  | [hd, ...tl] =>
    tl |> List.fold_left((acc, nodes) => acc @ [sep] @ nodes, hd)
  };
};

let lonaValue = (colors, textStyles: TextStyle.file, value: Types.lonaValue) =>
  switch value.ltype {
  | Reference(typeName) =>
    switch typeName {
    | "Boolean" => LiteralExpression(Boolean(value.data |> Json.Decode.bool))
    | "Number" =>
      LiteralExpression(FloatingPoint(value.data |> Json.Decode.float))
    | "String" => LiteralExpression(String(value.data |> Json.Decode.string))
    | _ => SwiftIdentifier("UnknownReferenceType: " ++ typeName)
    }
  | Named(alias, subtype) =>
    switch alias {
    | "Color" =>
      let rawValue = value.data |> Json.Decode.string;
      switch (Color.find(colors, rawValue)) {
      | Some(color) =>
        MemberExpression([
          SwiftIdentifier("Colors"),
          SwiftIdentifier(color.id)
        ])
      | None => LiteralExpression(Color(rawValue))
      };
    | "TextStyle" =>
      let rawValue = value.data |> Json.Decode.string;
      switch (TextStyle.find(textStyles.styles, rawValue)) {
      | Some(textStyle) =>
        MemberExpression([
          SwiftIdentifier("TextStyles"),
          SwiftIdentifier(textStyle.id)
        ])
      | None =>
        MemberExpression([
          SwiftIdentifier("TextStyles"),
          SwiftIdentifier(textStyles.defaultStyle.id)
        ])
      };
    | _ => SwiftIdentifier("UnknownNamedTypeAlias" ++ alias)
    }
  };

let importFramework = framework =>
  switch framework {
  | SwiftOptions.UIKit => ImportDeclaration("UIKit")
  | SwiftOptions.AppKit => ImportDeclaration("AppKit")
  };

let colorTypeName = framework =>
  switch framework {
  | SwiftOptions.UIKit => "UIColor"
  | SwiftOptions.AppKit => "NSColor"
  };

let fontTypeName = framework =>
  switch framework {
  | SwiftOptions.UIKit => "UIFont"
  | SwiftOptions.AppKit => "NSFont"
  };

let layoutPriorityTypeDoc = framework =>
  switch framework {
  | SwiftOptions.UIKit => SwiftIdentifier("UILayoutPriority")
  | SwiftOptions.AppKit =>
    MemberExpression([
      SwiftIdentifier("NSLayoutConstraint"),
      SwiftIdentifier("Priority")
    ])
  };

let labelAttributedTextName = framework =>
  switch framework {
  | SwiftOptions.UIKit => "attributedText"
  | SwiftOptions.AppKit => "attributedStringValue"
  };
