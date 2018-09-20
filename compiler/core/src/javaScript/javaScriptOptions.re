[@bs.deriving accessors]
type framework =
  | ReactDOM
  | ReactNative
  | ReactSketchapp;

[@bs.deriving jsConverter]
type options = {framework};
