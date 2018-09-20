[@bs.deriving accessors]
type preset =
  | Standard
  | Airbnb;

[@bs.deriving jsConverter]
type options = {
  preset,
  filterComponents: option(string),
};
