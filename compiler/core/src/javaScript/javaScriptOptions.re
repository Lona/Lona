[@bs.deriving accessors]
type framework =
  | ReactDOM
  | ReactNative
  | ReactSketchapp;

type styleFramework =
  | None
  | StyledComponents;

[@bs.deriving jsConverter]
type options = {
  framework,
  styleFramework,
};