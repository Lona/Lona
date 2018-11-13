let styleVariableName = name => Format.camelCase(name);
let elementName = name => Format.safeVariableName(name);

let wrapperElementName = name => elementName(name) ++ "Wrapper";

let imageResizeModeHelperName = resizeMode =>
  styleVariableName("imageResizeMode" ++ Format.upperFirst(resizeMode));