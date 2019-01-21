type accessibilityElement = {label: option(string)};

type accessibilityType =
  | Auto
  | None
  | Element(accessibilityElement)
  | Container(list(string));