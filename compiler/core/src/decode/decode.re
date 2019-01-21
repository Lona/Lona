include Types;

open Json.Decode;

exception UnknownParameter(string);

let parameterType = key =>
  switch (key) {
  | ParameterKey.Text => Types.stringType
  | Visible => Types.booleanType
  | NumberOfLines => Types.numberType
  | BackgroundColor => Types.colorType
  | Opacity => Types.numberType
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
  | BorderColor => Types.colorType
  | BorderRadius => Types.numberType
  | BorderStyle => Types.stringType
  | BorderWidth => Types.numberType
  | Width => Types.numberType
  | MaxWidth => Types.stringType
  | Height => Types.numberType
  | MaxHeight => Types.stringType
  | TextStyle => Types.textStyleType
  | Shadow => Types.shadowType
  | ResizeMode => Types.stringType
  | Position => Types.stringType
  | Overflow => Types.stringType
  /* Interactivity */
  | Pressed => Types.booleanType
  | Hovered => Types.booleanType
  | OnPress => Types.handlerType
  /* Accessibility */
  | AccessibilityType => Types.stringType
  | AccessibilityLabel => Types.stringType
  | AccessibilityHint => Types.stringType
  | AccessibilityValue => Types.stringType
  | AccessibilityRole => Types.stringType
  | AccessibilityElements => Types.Array(Types.stringType)
  | OnAccessibilityActivate => Types.handlerType
  /* Custom */
  /* | Custom("font") => Types.textStyleType */
  | Custom(name) =>
    Js.log2("Unknown built-in parameter when deserializing:", name);
    raise(UnknownParameter(name));
  };

module Styles = {
  let optionalLonaValue = (name, ltype, json) =>
    switch (json |> optional(field(name, x => x))) {
    | Some(data) => Some({data, ltype})
    | None => None
    };
  let border = json: Styles.border(option(lonaValue)) => {
    borderColor: json |> optionalLonaValue("borderColor", colorType),
    borderRadius: json |> optionalLonaValue("borderRadius", numberType),
    borderStyle: json |> optionalLonaValue("borderStyle", stringType),
    borderWidth: json |> optionalLonaValue("borderWidth", numberType),
  };
  let edgeInsets = (prefix, json): Styles.edgeInsets(option(lonaValue)) => {
    top: json |> optionalLonaValue(prefix ++ "Top", numberType),
    right: json |> optionalLonaValue(prefix ++ "Right", numberType),
    bottom: json |> optionalLonaValue(prefix ++ "Bottom", numberType),
    left: json |> optionalLonaValue(prefix ++ "Left", numberType),
  };
  let flexLayout = json: Styles.flexLayout(option(lonaValue)) => {
    alignItems: json |> optionalLonaValue("alignItems", stringType),
    alignSelf: json |> optionalLonaValue("alignSelf", stringType),
    display: json |> optionalLonaValue("display", stringType),
    justifyContent: json |> optionalLonaValue("justifyContent", stringType),
    flexDirection: json |> optionalLonaValue("flexDirection", stringType),
    flex: json |> optionalLonaValue("flex", numberType),
    width: json |> optionalLonaValue("width", numberType),
    height: json |> optionalLonaValue("height", numberType),
  };
  let layout = json: Styles.layout(option(lonaValue)) => {
    flex: json |> flexLayout,
    padding: json |> edgeInsets("padding"),
    margin: json |> edgeInsets("margin"),
  };
  let textStyles = json: Styles.textStyles(option(lonaValue)) => {
    textAlign: json |> optionalLonaValue("textAlign", stringType),
    textStyle: json |> optionalLonaValue("textStyle", stringType),
  };
  let viewLayerStyles = json: Styles.viewLayerStyles(option(lonaValue)) => {
    layout: json |> layout,
    border: json |> border,
    backgroundColor: json |> optionalLonaValue("backgroundColor", colorType),
    textStyles: json |> textStyles,
  };
  let styleSets = json: list(Styles.namedStyles(option(lonaValue))) =>
    json
    |> Js.Json.decodeObject
    |> Js.Option.getExn
    |> Js.Dict.entries
    |> (
      x =>
        Array.to_list(x)
        |> List.map(pair => {
             let (name, styleSet) = pair;
             (
               {name, styles: styleSet |> viewLayerStyles}:
                 Styles.namedStyles(option(lonaValue))
             );
           })
    );
};

module Parameters = {
  let parameterKey = json => json |> string |> ParameterKey.fromString;
  let parameter = json => {
    name: json |> field("name", parameterKey),
    ltype: json |> field("type", UserTypes.Decode.lonaType),
    defaultValue: json |> optional(field("defaultValue", x => x)),
  };
};

module Layer = {
  let layerType = json =>
    switch (string(json)) {
    | "Lona:View" => View
    | "Lona:Text" => Text
    | "Lona:Image" => Image
    | "Lona:VectorGraphic" => VectorGraphic
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
      |> ParameterMap.filter((key, value) =>
           switch (key) {
           | Custom("styles") => false
           | _ => true
           }
         )
      |> ParameterMap.mapi((key, value) =>
           switch (typeName) {
           | Component(name) =>
             let param =
               getComponent(name)
               |> field("params", list(Parameters.parameter))
               |> List.find((param: parameter) => param.name == key);
             switch (param) {
             | _ =>
               LonaValue.expandDecodedValue({ltype: param.ltype, data: value})
             | exception _ =>
               Js.log2(
                 "Unknown built-in parameter when deserializing component:",
                 key,
               );
               raise(UnknownParameter(ParameterKey.toString(key)));
             };
           | _ => {ltype: parameterType(key), data: value}
           }
         );
    let name = field("id", string, json);
    {
      typeName,
      name,
      styles:
        switch (
          json |> optional(at(["params", "styles"], Styles.styleSets))
        ) {
        | Some(a) => a
        | None => [LonaCompilerCore.Styles.emptyNamedStyle("normal")]
        },
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
      metadata: {
        accessLevel:
          json
          |> DecodeMetadata.platformSpecificValue(
               ["metadata", "accessLevel"],
               DecodeMetadata.fieldDecoder(
                 DecodeMetadata.accessLevel,
                 Types.Private,
               ),
             ),
        backingElementClass:
          json
          |> DecodeMetadata.platformSpecificValue(
               ["metadata", "backingElementClass"],
               DecodeMetadata.fieldDecoder(optional(string), None),
             ),
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
      LiteralExpression(
        LonaValue.expandDecodedValue({
          ltype: json |> at(["value", "type"], UserTypes.Decode.lonaType),
          data: json |> at(["value", "data"], json => json),
        }),
      )
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
      let ltype = Reference("UnknownReferenceType");
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
      | VariableDeclarationExpression(o) =>
        let id = o##identifier |> identifierFromExpr;
        let content = o##content |> logicValueFromExpr;
        Logic.LetEqual(Logic.Identifier(undefinedType, [id]), content);
      | IfExpression(o) =>
        let body = o##body |> List.map(fromExpr);
        switch (o##condition) {
        | VariableDeclarationExpression(decl) =>
          let id = decl##identifier |> identifierFromExpr;
          let content = decl##content |> logicValueFromExpr;
          Logic.IfLet(
            Logic.Identifier(undefinedType, [id]),
            content,
            Logic.Block(body),
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
};

module Component = {
  open Json.Decode;
  let parameters = json => field("params", list(Parameters.parameter), json);
  let rootLayer = (getComponent, json) =>
    field("root", Layer.layer(getComponent), json);
  let logic = json => Logic.Block(field("logic", list(logicNode), json));
};

/* For JS API */
let decodeParameters = Component.parameters;

let decodeRootLayer = Component.rootLayer;

let decodeLogic = Component.logic;