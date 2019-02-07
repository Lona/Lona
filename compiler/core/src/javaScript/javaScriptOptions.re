[@bs.deriving accessors]
type framework =
  | ReactDOM
  | ReactNative
  | ReactSketchapp;

type styleFramework =
  | None
  | StyledComponents;

type styledComponentsVersion =
  | V3
  | Latest;

[@bs.deriving jsConverter]
type options = {
  framework,
  styleFramework,
  styledComponentsVersion,
};