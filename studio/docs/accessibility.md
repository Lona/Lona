# Lona accessibility support

Lona provides a set of cross-platform parameters to build accessible components. In cases where these aren't enough, the native views can be manipulated directly via code.

- [Accessibility parameters](#accessibility-parameters)
- [Swift](#swift)
- [JavaScript](#javascript)

## Accessibility parameters

Lona supports the following layer parameters to generate accessible UI components. These parameters are modeled after iOS and React Native accessibility support. Some parameters are **static**, some are **dynamic**, and some are both. Static parameters can be given a default value (at compile-time). Dynamic parameters can be assigned via Lona Logic (at runtime).

#### `accessibilityType` (static)

_Supported on iOS & web_

Type: one of `"default"`, `"none"`, `"element"`, `"container"`. Default: `"default"`.

This configures overall the behavior of the layer. This parameter is unique to Lona and doesn't directly translate to any platform. Instead, Lona uses it to set other platform-specific parameters.

- **`default`** - Use the platform default values for the layer. For example, Text layers automatically have their `accessibilityLabel` set to the same value as the text. It's best to use `none`, `element`, or `container` instead to explicitly define the behavior, rather than letting the platform guess.
- **`none`** - The layer is hidden from assistive technologies.
- **`element`** - This layer is focusable by assistive technologies. Lona Studio requires this to be set before it will reveal most of the other parameters (e.g. `AccessibilityLabel`).
- **`container`** - This contains accessible descendant layers. These can be configured by id using the `accessibilityElements` parameter.

#### `accessibilityLabel` (static & dynamic)

_Supported on iOS & web_

Type: `String`

A screenreader reads this text when the user focuses the layer.

#### `accessibilityHint` (static & dynamic)

_Currently supported on iOS_

Type: `String`

A screenreader reads this text after reading the `accessibilityLabel` and other information. This can suggest how the layer should be used, e.g. "double tap to add to cart".

#### `accessibilityValue` (dynamic)

_Currently supported on iOS_

Type: `String`

Use this when working with interactive controls. For example, a number input field would set the `accessibilityValue` to the current number value.

#### `accessibilityRole` (static)

_Currently supported on iOS_

Type: one of `"none"`, `"button"`, `"link"`, `"search"`, `"image"`, `"keyboardkey"`, `"text"`, `"adjustable"`, `"imagebutton"`, `"header"`, `"summary"`

These presets determine the high level behavior of the layer. Currently this list is taken from React Native and should handle mobile fairly well, but there may be more to add for web.

#### `accessibilityElements` (static & dynamic†)

_Supported on iOS & web_

Type: `Array<String>`

This can be set after `accessibilityType` has been set to `container`. This is the list of descendant layers which assistive technologies should read. Any layer specified in this array will likely also need its own `accessibilityType` set to `elements`.

† - can only be assigned an array of hardcoded values. E.g. different conditional branches can assign different sets of hardcoded values. These are transformed at compile-time.

#### `accessibilitySelectedState` (dynamic)

_Not supported yet_

Type: `Boolean`

Use this for interactive controls that have selectable elements, e.g. a list of tabs. In a list of tabs, each tab will be _focusable_, but likely only one will be _selected_ at any time.

#### `accessibilityDisabledState` (dynamic)

_Not supported yet_

Type: `Boolean`

Use this for interactive controls that can't currently be interactive with, e.g. a "submit" button in a form when some of the required fields are empty.

#### `onAccessibilityActivate` (dynamic)

_Supported on iOS & web_

Type: `Function<Void> -> Void`

A callback for when an element is activated via keyboard or assistive technologies. This is analogous to `onPress`, and should often do the same thing.
