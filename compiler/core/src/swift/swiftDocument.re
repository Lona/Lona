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

let nameWithoutExtension = path => {
  let obj: Node.Path.pathObject = Node.Path.parse(path);
  obj##name;
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

let imageTypeName = framework =>
  switch framework {
  | SwiftOptions.UIKit => "UIImage"
  | SwiftOptions.AppKit => "NSImage"
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

let localImageName = (framework: SwiftOptions.framework, name) => {
  let imageName = LiteralExpression(String(nameWithoutExtension(name)));
  switch framework {
  | SwiftOptions.UIKit => imageName
  | SwiftOptions.AppKit =>
    FunctionCallExpression({
      "name":
        MemberExpression([SwiftIdentifier("NSImage"), SwiftIdentifier("Name")]),
      "arguments": [
        FunctionCallArgument({
          "name": Some(SwiftIdentifier("rawValue")),
          "value": imageName
        })
      ]
    })
  };
};

let typeAnnotationDoc =
  fun
  | Types.Reference(typeName) =>
    switch typeName {
    | "Boolean" => TypeName("Bool")
    | _ => TypeName(typeName)
    }
  | Named(name, _) => TypeName(name)
  | Function(_, _) => TypeName("(() -> Void)?");

let rec lonaValue =
        (
          framework: SwiftOptions.framework,
          colors,
          textStyles: TextStyle.file,
          value: Types.lonaValue
        ) =>
  switch value.ltype {
  | Reference(typeName) =>
    switch typeName {
    | "Boolean" => LiteralExpression(Boolean(value.data |> Json.Decode.bool))
    | "Number" =>
      LiteralExpression(FloatingPoint(value.data |> Json.Decode.float))
    | "String" => LiteralExpression(String(value.data |> Json.Decode.string))
    | "TextStyle"
    | "Color" =>
      lonaValue(
        framework,
        colors,
        textStyles,
        {ltype: Named(typeName, Reference("String")), data: value.data}
      )
    | _ => SwiftIdentifier("UnknownReferenceType: " ++ typeName)
    }
  | Function(_) => SwiftIdentifier("PLACEHOLDER")
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
    | "URL" =>
      let rawValue = value.data |> Json.Decode.string;
      if (rawValue |> Js.String.startsWith("file://./")) {
        FunctionCallExpression({
          "name": SwiftIdentifier(imageTypeName(framework)),
          "arguments": [
            FunctionCallArgument({
              "name": Some(SwiftIdentifier("named")),
              "value": localImageName(framework, rawValue)
            })
          ]
        });
      } else {
        SwiftIdentifier("RemoteOrAbsoluteImageNotHandled");
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

let memberOrSelfExpression = (first, statements) =>
  switch first {
  | SwiftIdentifier("self") => MemberExpression(statements)
  | _ => MemberExpression([first] @ statements)
  };

let layerNameOrSelf = (rootLayer, layer: Types.layer) =>
  SwiftIdentifier(
    layer === rootLayer ? "self" : layer.name |> SwiftFormat.layerName
  );

let layerMemberExpression = (rootLayer, layer: Types.layer, statements) =>
  memberOrSelfExpression(layerNameOrSelf(rootLayer, layer), statements);

let rec binaryExpressionList = (operator, items) =>
  switch items {
  | [] => Empty
  | [x] => x
  | [hd, ...tl] =>
    BinaryExpression({
      "left": hd,
      "operator": operator,
      "right": binaryExpressionList(operator, tl)
    })
  };