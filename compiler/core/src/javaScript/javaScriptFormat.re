let styleVariableName = name => Format.camelCase(name);
let elementName = name => Format.safeVariableName(name);

let enumName = name => name |> Format.snakeCase |> Js.String.toUpperCase;
let enumCaseName = name => name |> Format.snakeCase |> Js.String.toUpperCase;

let wrapperElementName = (componentName, layerName) =>
  elementName(componentName)
  ++ Format.upperFirst(
       Format.camelCase(Format.safeVariableName(layerName)),
     )
  ++ "Wrapper";

let imageResizeModeHelperName = resizeMode =>
  styleVariableName("imageResizeMode" ++ Format.upperFirst(resizeMode));