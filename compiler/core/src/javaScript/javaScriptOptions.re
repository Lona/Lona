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

type minimumIeSupport =
  | None
  | IE11;

[@bs.deriving jsConverter]
type options = {
  framework,
  styleFramework,
  styledComponentsVersion,
  minimumIeSupport,
};