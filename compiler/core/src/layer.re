module LayerMap = {
  include
    Map.Make(
      {
        type t = Types.layer;
        let compare = (a: t, b: t) : int =>
          switch (a, b) {
          | (Layer(_, aName, _, _), Layer(_, bName, _, _)) => compare(aName, bName)
          };
      }
    );
  let find_opt = (key, map) =>
    switch (find(key, map)) {
    | item => Some(item)
    | exception Not_found => None
    };
};

let parameterTypeMap =
  [
    ("text", Types.Reference("String")),
    ("visible", Types.Reference("Boolean")),
    /* Styles */
    ("alignItems", Types.Reference("String")),
    ("alignSelf", Types.Reference("String")),
    ("flex", Types.Reference("Number")),
    ("flexDirection", Types.Reference("String")),
    ("font", Types.Reference("String")),
    ("justifyContent", Types.Reference("String")),
    ("marginTop", Types.Reference("Number")),
    ("marginRight", Types.Reference("Number")),
    ("marginBottom", Types.Reference("Number")),
    ("marginLeft", Types.Reference("Number")),
    ("paddingTop", Types.Reference("Number")),
    ("paddingRight", Types.Reference("Number")),
    ("paddingBottom", Types.Reference("Number")),
    ("paddingLeft", Types.Reference("Number"))
  ]
  |> StringMap.fromList;

let stylesSet =
  StringSet.of_list([
    "alignItems",
    "alignSelf",
    "flex",
    "flexDirection",
    "font",
    "justifyContent",
    "marginTop",
    "marginRight",
    "marginBottom",
    "marginLeft",
    "paddingTop",
    "paddingRight",
    "paddingBottom",
    "paddingLeft"
  ]);

let parameterType = (name) =>
  switch (StringMap.find(name, parameterTypeMap)) {
  | item => item
  | exception Not_found =>
    Js.log2("Unknown built-in parameter when deserializing:", name);
    Reference("Null")
  };

let flatten = (layer) => {
  let rec inner = (acc, layer) =>
    switch layer {
    | Types.Layer(_, _, _, children) =>
      List.flatten([acc, [layer], ...List.map(inner([]), children)])
    };
  inner([], layer)
};

let find = (name, layer) => {
  let matches = (item) =>
    switch item {
    | Types.Layer(_, itemName, _, _) => name == itemName
    };
  switch (List.find(matches, flatten(layer))) {
  | item => Some(item)
  | exception Not_found => None
  }
};

let parameterAssignments = (layer, node) => {
  let identifiers = Logic.undeclaredIdentifiers(node);
  let updateAssignments = (layerName, propertyName, logicValue, acc) =>
    switch (find(layerName, layer)) {
    | Some(found) =>
      switch (LayerMap.find_opt(found, acc)) {
      | Some(x) => LayerMap.add(found, StringMap.add(propertyName, logicValue, x), acc)
      | None => LayerMap.add(found, StringMap.add(propertyName, logicValue, StringMap.empty), acc)
      }
    | None => acc
    };
  identifiers
  |> Logic.IdentifierSet.elements
  |> List.map(((type_, path)) => Logic.Identifier(type_, path))
  |> List.fold_left(
       (acc, item) =>
         switch item {
         | Logic.Identifier(_, [_, layerName, propertyName]) =>
           updateAssignments(layerName, propertyName, item, acc)
         | _ => acc
         },
       LayerMap.empty
     )
};

let parameterIsStyle = (name) => StringSet.has(name, stylesSet);

let splitParamsMap = (params) => params |> StringMap.partition((key, _) => parameterIsStyle(key));

let parameterMapToLogicValueMap = (params) => StringMap.map((item) => Logic.Literal(item), params);

let layerTypeToString = (x) =>
  switch x {
  | Types.View => "View"
  | Text => "Text"
  | Image => "Image"
  | Animation => "Animation"
  | Children => "Children"
  | Component => "Component"
  | Unknown => "Unknown"
  };

let mapBindings = (f, map) => map |> StringMap.bindings |> List.map(f);

let rec createStyleAttributeAST = (layerName, styles) =>
  Ast.JavaScript.(
    JSXAttribute(
      "style",
      ArrayLiteral([
        Identifier(["styles", layerName]),
        ObjectLiteral(
          styles
          |> mapBindings(
               ((key, value)) =>
                 ObjectProperty(Identifier([key]), Logic.logicValueToJavaScriptAST(value))
             )
        )
      ])
    )
  );

let rec toJavaScriptAST = (variableMap, layer) =>
  Ast.JavaScript.(
    switch layer {
    | Types.Layer(layerType, name, params, children) =>
      let (_, mainParams) = params |> parameterMapToLogicValueMap |> splitParamsMap;
      let (styleVariables, mainVariables) =
        (
          switch (LayerMap.find_opt(layer, variableMap)) {
          | Some(map) => map
          | None => StringMap.empty
          }
        )
        |> splitParamsMap;
      let main = StringMap.assign(mainParams, mainVariables);
      let styleAttribute = createStyleAttributeAST(name, styleVariables);
      let attributes =
        main
        |> mapBindings(((key, value)) => JSXAttribute(key, Logic.logicValueToJavaScriptAST(value)));
      JSXElement(
        layerTypeToString(layerType),
        [styleAttribute, ...attributes],
        children |> List.map(toJavaScriptAST(variableMap))
      )
    }
  );

let toJavaScriptStyleSheetAST = (layer) => {
  open Ast.JavaScript;
  let createStyleObjectForLayer = (layer) =>
    switch layer {
    | Types.Layer(_, name, params, _) =>
      let styleParams = params |> StringMap.filter((key, _) => parameterIsStyle(key));
      ObjectProperty(
        Identifier([name]),
        ObjectLiteral(
          styleParams
          |> StringMap.bindings
          |> List.map(((key, value)) => ObjectProperty(Identifier([key]), Literal(value)))
        )
      )
    };
  let styleObjects = layer |> flatten |> List.map(createStyleObjectForLayer);
  VariableDeclaration(
    AssignmentExpression(
      Identifier(["styles"]),
      CallExpression(Identifier(["StyleSheet", "create"]), [ObjectLiteral(styleObjects)])
    )
  )
};