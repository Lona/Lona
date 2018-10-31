type t =
  | Custom(string)
  /* Built-in */
  | Visible
  /* Text */
  | Text
  | TextAlign
  /* TODO: We should try to use just TextStyle. Change font => textStyle in save format? */
  /* | Font */
  | TextStyle
  | NumberOfLines
  /* Image */
  | Image
  /* Styles */
  | AlignItems
  | AlignSelf
  | BackgroundColor
  | Display
  | Flex
  | FlexDirection
  | JustifyContent
  | MarginTop
  | MarginRight
  | MarginBottom
  | MarginLeft
  | Overflow
  | PaddingTop
  | PaddingRight
  | PaddingBottom
  | PaddingLeft
  | BorderRadius
  | BorderWidth
  | BorderColor
  | Shadow
  | Width
  | MaxWidth
  | Height
  | MaxHeight
  /* Interactivity */
  | Pressed
  | Hovered
  | OnPress;

let fromString = string =>
  switch (string) {
  /* Built-in */
  | "visible" => Visible
  /* Text */
  | "text" => Text
  | "textAlign" => TextAlign
  | "font" => TextStyle
  | "textStyle" => TextStyle
  | "numberOfLines" => NumberOfLines
  /* Image */
  | "image" => Image
  /* Styles */
  | "alignItems" => AlignItems
  | "alignSelf" => AlignSelf
  | "backgroundColor" => BackgroundColor
  | "display" => Display
  | "flex" => Flex
  | "flexDirection" => FlexDirection
  | "justifyContent" => JustifyContent
  | "marginTop" => MarginTop
  | "marginRight" => MarginRight
  | "marginBottom" => MarginBottom
  | "marginLeft" => MarginLeft
  | "overflow" => Overflow
  | "paddingTop" => PaddingTop
  | "paddingRight" => PaddingRight
  | "paddingBottom" => PaddingBottom
  | "paddingLeft" => PaddingLeft
  | "borderRadius" => BorderRadius
  | "borderWidth" => BorderWidth
  | "borderColor" => BorderColor
  | "shadow" => Shadow
  | "width" => Width
  | "maxWidth" => Width
  | "height" => Height
  | "maxHeight" => Height
  /* Interactivity */
  | "pressed" => Pressed
  | "hovered" => Hovered
  | "onPress" => OnPress
  /* Custom */
  | x => Custom(x)
  };

let toString = key =>
  switch (key) {
  /* Built-in */
  | Visible => "visible"
  /* Text */
  | Text => "text"
  | TextAlign => "textAlign"
  | TextStyle => "textStyle"
  | NumberOfLines => "numberOfLines"
  /* Image */
  | Image => "image"
  /* Styles */
  | AlignItems => "alignItems"
  | AlignSelf => "alignSelf"
  | BackgroundColor => "backgroundColor"
  | Display => "display"
  | Flex => "flex"
  | FlexDirection => "flexDirection"
  | JustifyContent => "justifyContent"
  | MarginTop => "marginTop"
  | MarginRight => "marginRight"
  | MarginBottom => "marginBottom"
  | MarginLeft => "marginLeft"
  | Overflow => "overflow"
  | PaddingTop => "paddingTop"
  | PaddingRight => "paddingRight"
  | PaddingBottom => "paddingBottom"
  | PaddingLeft => "paddingLeft"
  | BorderRadius => "borderRadius"
  | BorderWidth => "borderWidth"
  | BorderColor => "borderColor"
  | Shadow => "shadow"
  | Width => "width"
  | MaxWidth => "maxWidth"
  | Height => "height"
  | MaxHeight => "maxHeight"
  /* Interactivity */
  | Pressed => "pressed"
  | Hovered => "hovered"
  | OnPress => "onPress"
  /* Custom */
  | Custom(x) => x
  };