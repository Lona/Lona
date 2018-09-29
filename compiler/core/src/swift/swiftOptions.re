[@bs.deriving accessors]
type framework =
  | UIKit
  | AppKit;

let frameworkToString =
  fun
  | UIKit => "uikit"
  | AppKit => "appkit";

[@bs.deriving jsConverter]
type options = {
  framework,
  debugConstraints: bool,
  typePrefix: string,
};