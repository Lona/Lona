[@bs.deriving accessors]
type preset =
  | Standard
  | Airbnb;

[@bs.deriving jsConverter]
type options = {
  preset,
  filterComponents: option(string),
  swift: SwiftOptions.options,
  javaScript: JavaScriptOptions.options,
};