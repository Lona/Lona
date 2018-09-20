include Types;

open Json.Decode;

exception UnknownParameter(string);

exception UnknownType(string);

let parameterType = key =>
  switch (key) {
  | ParameterKey.Text => Types.stringType
  | Visible => Types.booleanType
  | NumberOfLines => Types.numberType
  | BackgroundColor => Types.colorType
  | Image => Types.urlType
  /* Styles */
  | AlignItems => Types.stringType
  | AlignSelf => Types.stringType
  | Display => Types.stringType
  | Flex => Types.numberType
  | FlexDirection => Types.stringType
  | TextAlign => Types.stringType
  | JustifyContent => Types.stringType
  | MarginTop => Types.numberType
  | MarginRight => Types.numberType
  | MarginBottom => Types.numberType
  | MarginLeft => Types.numberType
  | PaddingTop => Types.numberType
  | PaddingRight => Types.numberType
  | PaddingBottom => Types.numberType
  | PaddingLeft => Types.numberType
  | BorderRadius => Types.numberType
  | BorderWidth => Types.numberType
  | BorderColor => Types.colorType
  | Width => Types.numberType
  | Height => Types.numberType
  | TextStyle => Types.textStyleType
  /* Interactivity */
  | Pressed => Types.booleanType
  | Hovered => Types.booleanType
  | OnPress => Types.handlerType
  /* Custom */
  /* | Custom("font") => Types.textStyleType */
  | Custom(name) =>
    Js.log2("Unknown built-in parameter when deserializing:", name);
    raise(UnknownParameter(name));
  };

module Types = {
  let rec lonaType = json => {
    let namedType = json => {
      let named = field("alias", string, json);
      let ltype = field("of", lonaType, json);
      Named(named, ltype);
    };
    let functionType = json => {
      let argumentType = json => {
        "label": field("label", string, json),
        "type": field("type", lonaType, json),
      };
      let arguments =
        switch (json |> optional(field("arguments", list(argumentType)))) {
        | Some(decoded) => decoded
        | None => []
        };
      let returnType =
        switch (
          json
          |> optional(field("arguments", field("returnType", lonaType)))
        ) {
        | Some(decoded) => decoded
        | None => Types.undefinedType
        };
      Function(arguments, returnType);
    };
    let referenceType = json => json |> string |> (x => Reference(x));
    let otherType = json => {
      let name = field("name", string, json);
      switch (name) {
      | "Named" => namedType(json)
      | "Function" => functionType(json)
      | _ => raise(UnknownType(name))
      };
    };
    json |> oneOf([referenceType, otherType]);
  };
};

module Parameters = {
  let parameterKey = json => json |> string |> ParameterKey.fromString;
  let parameter = json => {
    name: json |> field("name", parameterKey),
    ltype: json |> field("type", Types.lonaType),
    defaultValue: json |> optional(field("defaultValue", x => x)),
  };
};

module Layer = {
  let layerType = json =>
    switch (string(json)) {
    | "Lona:View" => View
    | "Lona:Text" => Text
    | "Lona:Image" => Image
    | "Lona:Animation" => Animation
    | "Lona:Children" => Children
    | value => Component(value)
    };
  let rec layer = (getComponent, json) => {
    let typeName = field("type", layerType, json);
    let parameterDictionary = json =>
      json
      |> Js.Json.decodeObject
      |> Js.Option.getExn
      |> ParameterMap.fromJsDict
      |> ParameterMap.mapi((key, value) =>
           switch (typeName) {
           | Component(name) =>
             let param =
               getComponent(name)
               |> field("params", list(Parameters.parameter))
               |> List.find((param: parameter) => param.name == key);
             switch (param) {
             | _ => {ltype: param.ltype, data: value}
             | exception _ =>
               Js.log2("Unknown built-in parameter when deserializing:", key);
               raise(UnknownParameter(ParameterKey.toString(key)));
             };
           | _ => {ltype: parameterType(key), data: value}
           }
         );
    let name = field("id", string, json);
    {
      typeName,
      name,
      parameters: field("params", parameterDictionary, json),
      children:
        switch (
          json |> optional(field("children", list(layer(getComponent))))
        ) {
        | Some(result) => result
        | None => []
        | exception e =>
          Js.log3(
            "Failed to decode children of",
            typeName |> LonaCompilerCore.Types.layerTypeToString,
            name,
          );
          raise(e);
        },
    };
  };
};

exception UnknownExprType(string);

let rec decodeExpr = json => {
  open LonaLogic;
  let decodePlaceholder = _ => PlaceholderExpression;
  let decodeIdentifier = json => IdentifierExpression(json |> string);
  let decodeMemberExpression = json =>
    MemberExpression(json |> list(decodeExpr));
  let decodeTypedExpr = json => {
    let exprType = json |> field("type", string);
    switch (exprType) {
    | "AssignExpr" =>
      AssignmentExpression({
        "assignee": json |> field("assignee", decodeExpr),
        "content": json |> field("content", decodeExpr),
      })
    | "IfExpr" =>
      IfExpression({
        "condition": json |> field("condition", decodeExpr),
        "body": json |> field("body", list(decodeExpr)),
      })
    | "VarDeclExpr" =>
      VariableDeclarationExpression({
        "content": json |> field("content", decodeExpr),
        "identifier": json |> field("id", decodeExpr),
      })
    | "BinExpr" =>
      BinaryExpression({
        "left": json |> field("left", decodeExpr),
        "op": json |> field("op", decodeExpr),
        "right": json |> field("right", decodeExpr),
      })
    | "LitExpr" =>
      LiteralExpression({
        ltype: json |> at(["value", "type"], Types.lonaType),
        data: json |> at(["value", "data"], json => json),
      })
    | _ => raise(UnknownExprType(exprType))
    };
  };
  oneOf([
    decodeTypedExpr,
    decodeIdentifier,
    decodeMemberExpression,
    decodePlaceholder,
  ]) @@
  json;
};

exception UnknownLogicValue(string);

let rec logicNode = json => {
  let cmp = str =>
    switch (str) {
    | "==" => Eq
    | "!=" => Neq
    | ">" => Gt
    | ">=" => Gte
    | "<" => Lt
    | "<=" => Lte
    | _ => Unknown
    };
  let identifierFromExpr = expr =>
    switch (expr) {
    | LonaLogic.IdentifierExpression(str) => str
    | _ => raise(UnknownExprType("Expected identifier"))
    };
  let rec logicValueFromExpr = expr =>
    switch (expr) {
    | LonaLogic.MemberExpression(items) =>
      let ltype = Reference("???");
      let path = items |> List.map(identifierFromExpr);
      Logic.Identifier(ltype, path);
    | LonaLogic.LiteralExpression(value) => Logic.Literal(value)
    | _ => raise(UnknownExprType("Failed to convert logic value"))
    }
  and fromExpr = expr =>
    LonaLogic.(
      switch (expr) {
      | AssignmentExpression(o) =>
        let content = o##content |> logicValueFromExpr;
        let assignee = o##assignee |> logicValueFromExpr;
        Logic.Assign(content, assignee);
      | IfExpression(o) =>
        let body = o##body |> List.map(fromExpr);
        switch (o##condition) {
        | VariableDeclarationExpression(decl) =>
          let id = decl##identifier |> identifierFromExpr;
          let content = decl##content |> logicValueFromExpr;
          Logic.IfExists(
            content,
            Logic.Block([
              Logic.LetEqual(
                Logic.Identifier(undefinedType, [id]),
                content,
              ),
              ...body,
            ]),
          );
        | BinaryExpression(bin) =>
          let left = bin##left |> logicValueFromExpr;
          let right = bin##right |> logicValueFromExpr;
          let op = bin##op |> identifierFromExpr |> cmp;
          Logic.If(left, op, right, Logic.Block(body));
        | AssignmentExpression(_) =>
          raise(UnknownExprType("Unknown AssignmentExpression"))
        | IfExpression(_) => raise(UnknownExprType("Unknown IfExpression"))
        | MemberExpression(_) =>
          raise(UnknownExprType("Unknown MemberExpression"))
        | IdentifierExpression(_) =>
          raise(UnknownExprType("Unknown IdentifierExpression"))
        | LiteralExpression(_) =>
          raise(UnknownExprType("Unknown LiteralExpression"))
        | PlaceholderExpression =>
          raise(UnknownExprType("Unknown PlaceholderExpression"))
        };
      | _ => Logic.None
      }
    );
  fromExpr(decodeExpr(json));
  /* switch (at(["function", "name"], string, json)) {
     | "assign(lhs, to rhs)" =>
       Logic.Assign(arg(["lhs"], value), arg(["rhs"], value))
     | "if(lhs, is cmp, rhs)" =>
       If(
         arg(["lhs"], value),
         arg(["cmp", "value", "data"], cmp),
         arg(["rhs"], value),
         Block(nodes)
       )
     | "if(value)" => IfExists(arg(["value"], value), Block(nodes))
     | "add(lhs, to rhs, and assign to value)" =>
       Add(arg(["lhs"], value), arg(["rhs"], value), arg(["value"], value))
     | _ => None
     }; */
};

module Component = {
  let parameters = json => field("params", list(Parameters.parameter), json);
  let rootLayer = (getComponent, json) =>
    field("root", Layer.layer(getComponent), json);
  let logic = json => Logic.Block(field("logic", list(logicNode), json));
};

/* For JS API */
let decodeParameters = Component.parameters;

let decodeRootLayer = Component.rootLayer;

let decodeLogic = Component.logic;
