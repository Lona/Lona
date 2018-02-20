[@bs.deriving accessors]
type framework =
  | UIKit
  | AppKit;

[@bs.deriving jsConverter]
type options = {framework};