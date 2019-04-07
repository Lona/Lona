[@bs.deriving accessors]
type framework =
  | UIKit
  | AppKit;

let frameworkToString =
  fun
  | UIKit => "uikit"
  | AppKit => "appkit";

type swiftVersion =
  | V4
  | V5;

[@bs.deriving jsConverter]
type options = {
  framework,
  debugConstraints: bool,
  typePrefix: string,
  generateCollectionView: bool,
  swiftVersion: swiftVersion,
};