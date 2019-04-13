# Color Definitions

This file defines the design system's colors.

## Specification

At the top level, the file is an object containing:

- a `theme` array
- a `colors` array

### `theme`

The `theme` array is optional. The default theme is the first item of the array, if any.

Each theme has the following attributes:

| Attribute  | Type     | Required | Description                                                                                                                                                                                                                                                                                                            |
| ---------- | -------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`       | `string` | Yes      | The unique `id` of the theme, which will be used internally by Lona Studio and in the generated code. This should be _code-friendly_: it must not contain spaces or unusual characters, since it will be used as a variable name. It should also be strictly longer than 1 character and cannot be equal to `extends`. |
| `name`     | `string` | Yes      | The human-readable name of the theme. This will be displayed in the Lona Studio UI. This will not appear in the generated code.                                                                                                                                                                                        |
| `comment`  | `string` | No       | An optional description of the theme, explaining contextual information, such as how it should be used. This may be displayed in the Lona Studio UI. This will not appear in the generated code.                                                                                                                       |
| `metadata` | `object` | No       | Additional data used by the generated code to match platform specific features (for example `metadata.isMacOSDarkTheme` indicates that the theme should be used when the macOS system theme is `dark`).                                                                                                                |

### `colors`

The `colors` array is required.

Each color has the following attributes:

| Attribute  | Type      | Required                           | Description                                                                                                                                                                                                                       |
| ---------- | --------- | ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`       | `string`  | Yes                                | The unique `id` of the color, which will be used internally by Lona Studio and in the generated code. This should be _code-friendly_: it must not contain spaces or unusual characters, since it will be used as a variable name. |
| `name`     | `string`  | Yes                                | The human-readable name of the color. This will be displayed in the Lona Studio UI. This will not appear in the generated code.                                                                                                   |
| `value`    | `object`  | Required if there is no `variants` | An object representing the color. See [Color Value](#color-value) for more information about the properties of the object.                                                                                                        |
| `variants` | `Color[]` | Required if there is no `value`    | An array representing the variants of the color.                                                                                                                                                                                  |
| `comment`  | `string`  | No                                 | An optional description of the color, explaining contextual information, such as how it should be used. This may be displayed in the Lona Studio UI. This will not appear in the generated code.                                  |

> The reason why it's an array instead of an object with the id as keys is that we want to order colors, and it's really not recommended to rely on the order of the keys of a JSON object.

### Color Value

#### Value

The value of a color is represented by a JSON object. There are multiple ways to represent it, hence there are multiple set of properties available to represent the color.

- `hex`: `{ "hex": "#00FF00" }`
- `rgb`: `{ "r": 0, "g": 1, "b": 0 }`
- `hsl`: `{ "h": 120, "s": 1, "l": 0.5 }`
- `hsv`: `{ "h": 120, "s": 1, "v": 1 }`

Only one set of properties must be specified for a single value.

#### Aliasing or extending a color

Additionally, it is possible for a value to reference another color's value by their `id` (a `string`) and extend it. (Variants can be referenced by their "id path" (eg. `"colorId.variantId"`))

```json
{
  "extends": "anotherColorId"
}
```

Once a value extends another one, it can specified any subset of one of the set of properties used to represent a color.

For Example:

```json
[
  {
    "id": "baseColor",
    "name": "Base Color",
    "value": { "hex": "#00FF00" }
  }
  {
    "id": "desaturatedBaseColor",
    "name": "Desaturated Base Color",
    "value": {
      "extends": "baseColor",
      "s": 0.5
    }
  }
]
```

If no additional properties are specified, the color is effectively aliasing another one.

#### Theming

The value of a color can also depend on the theme. To specify the value of the color for a specific theme, use the `id` of the theme as the property name. The property value is the color value.

```json
{
  "theme": [
    { "id": "light", "name": "Light Theme" },
    { "id": "dark", "name": "Dark Theme" }
  ],
  "colors": [
    {
      "id": "textColor",
      "name": "Text Color",
      "value": {
        "hex": "#000000",
        "dark": {
          "hex": "#ffffff"
        }
      }
    }
  ]
}
```

If the value for the current theme is not specified, the root value will be used.

### Color Type

Colors may be referenced from other files by their `id` (a `string`). Variants can be referenced by their "id path" (eg. `colorId.variantId`). This helps us achieve a single source of truth for colors.

Colors may also appear _inline_ in other files (where a CSS color value is given directly), although this is discouraged for colors beyond `'black'`, `'white'`, and `'transparent'`.

## Sample File

`colors.json`

```json
{
  "colors": [
    {
      "id": "lonaTeal",
      "name": "Lona Teal",
      "value": "#008080",
      "comment": "Teal color for backgrounds"
    },
    {
      "id": "lonaBlue",
      "name": "Lona Blue",
      "value": "#000080",
      "comment": "Blue accent color"
    }
  ]
}
```
