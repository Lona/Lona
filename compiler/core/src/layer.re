module LayerMap = {
  include
    Map.Make(
      {
        type t = Types.layer;
        let compare = (a: t, b: t) : int => compare(a.name, b.name);
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
    ("numberOfLines", Types.Reference("Number")),
    ("backgroundColor", Types.colorType),
    ("image", Types.urlType),
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
    ("paddingLeft", Types.Reference("Number")),
    ("borderRadius", Types.Reference("Number")),
    ("width", Types.Reference("Number")),
    ("height", Types.Reference("Number"))
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
    "paddingLeft",
    "width",
    "height"
  ]);

let parameterType = (name) =>
  switch (StringMap.find(name, parameterTypeMap)) {
  | item => item
  | exception Not_found =>
    Js.log2("Unknown built-in parameter when deserializing:", name);
    Reference("BuiltIn-Null")
  };

let flatten = (layer: Types.layer) => {
  let rec inner = (acc, layer: Types.layer) => {
    let children = layer.children;
    List.flatten([acc, [layer], ...List.map(inner([]), children)])
  };
  inner([], layer)
};

let find = (name, layer: Types.layer) => {
  let matches = (item: Types.layer) => item.name == name;
  switch (List.find(matches, flatten(layer))) {
  | item => Some(item)
  | exception Not_found => None
  }
};

let flatmapParent = (f, layer: Types.layer) => {
  let rec inner = (layer: Types.layer) =>
    (layer.children |> List.map(f(Some(layer))))
    @ (layer.children |> List.map(inner) |> List.concat);
  [f(None, layer)] @ inner(layer)
};

let flatmap = (f, layer: Types.layer) => flatmapParent((_, layer) => f(layer), layer);

let getFlexDirection = (layer: Types.layer) =>
  switch (StringMap.find("flexDirection", layer.parameters)) {
  | value => value.data |> Json.Decode.string
  | exception Not_found => "column"
  };

let getNumberParameterOpt = (parameterName, layer: Types.layer) =>
  switch (StringMap.find(parameterName, layer.parameters)) {
  | value => Some(value.data |> Json.Decode.float)
  | exception Not_found => None
  };

let getNumberParameter = (parameterName, layer: Types.layer) =>
  switch (getNumberParameterOpt(parameterName, layer)) {
  | Some(value) => value
  | None => 0.0
  };

type edgeInsets = {
  top: float,
  right: float,
  bottom: float,
  left: float
};

let getInsets = (prefix, layer: Types.layer) => {
  let directions = ["Top", "Right", "Bottom", "Left"];
  let extract = (key) => StringMap.find_opt(prefix ++ key, layer.parameters);
  let unwrap =
    fun
    | Some((value: Types.lonaValue)) => value.data |> Json.Decode.float
    | None => 0.0;
  let values = directions |> List.map(extract) |> List.map(unwrap);
  let [top, right, bottom, left] = values;
  {top, right, bottom, left}
};

let getPadding = getInsets("padding");

let getMargin = getInsets("margin");

let parameterAssignmentsFromLogic = (layer, node) => {
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

let createStyleAttributeAST = (layerName, styles) =>
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

let rec toJavaScriptAST = (variableMap, layer: Types.layer) => {
  open Ast.JavaScript;
  let (_, mainParams) = layer.parameters |> parameterMapToLogicValueMap |> splitParamsMap;
  let (styleVariables, mainVariables) =
    (
      switch (LayerMap.find_opt(layer, variableMap)) {
      | Some(map) => map
      | None => StringMap.empty
      }
    )
    |> splitParamsMap;
  let main = StringMap.assign(mainParams, mainVariables);
  let styleAttribute = createStyleAttributeAST(layer.name, styleVariables);
  let attributes =
    main
    |> mapBindings(((key, value)) => JSXAttribute(key, Logic.logicValueToJavaScriptAST(value)));
  JSXElement(
    layerTypeToString(layer.typeName),
    [styleAttribute, ...attributes],
    layer.children |> List.map(toJavaScriptAST(variableMap))
  )
};

let toJavaScriptStyleSheetAST = (layer: Types.layer) => {
  open Ast.JavaScript;
  let createStyleObjectForLayer = (layer: Types.layer) => {
    let styleParams = layer.parameters |> StringMap.filter((key, _) => parameterIsStyle(key));
    ObjectProperty(
      Identifier([layer.name]),
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