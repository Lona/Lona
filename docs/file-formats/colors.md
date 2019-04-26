# Color Definitions

This file defines the design system's colors.

## Specification

At the top level, the file is an object containing:

- a `theme` array
- a `color-profiles` array
- a `colors` array

### `theme`

The `theme` array is optional. The default theme is the first item of the array, if any.

Each theme has the following attributes:

| Attribute  | Type     | Required | Description                                                                                                                                                                                                                       |
| ---------- | -------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`       | `string` | Yes      | The unique `id` of the theme, which will be used internally by Lona Studio and in the generated code. This should be _code-friendly_: it must not contain spaces or unusual characters, since it will be used as a variable name. |
| `name`     | `string` | Yes      | The human-readable name of the theme. This will be displayed in the Lona Studio UI. This will not appear in the generated code.                                                                                                   |
| `comment`  | `string` | No       | An optional description of the theme, explaining contextual information, such as how it should be used. This may be displayed in the Lona Studio UI. This will not appear in the generated code.                                  |
| `metadata` | `object` | No       | Additional data used by the generated code to match platform specific features (for example `metadata.isMacOSDarkTheme` indicates that the theme should be used when the macOS system theme is `dark`).                           |

### `color-profiles`

The `color-profiles` array is optional.

Each profile has the following attributes:

| Attribute | Type     | Required | Description                                                                                                                                                                                                                         |
| --------- | -------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`      | `string` | Yes      | The unique `id` of the profile, which will be used internally by Lona Studio and in the generated code. This should be _code-friendly_: it must not contain spaces or unusual characters, since it will be used as a variable name. |
| `name`    | `string` | Yes      | The human-readable name of the profile. This will be displayed in the Lona Studio UI. This will not appear in the generated code.                                                                                                   |
| `value`   | `string` | YES      | The URL to the color profile.                                                                                                                                                                                                       |
| `comment` | `string` | No       | An optional description of the profile, explaining contextual information, such as how it should be used. This may be displayed in the Lona Studio UI. This will not appear in the generated code.                                  |

#### Examples

```json
{
  "color-profiles": [
    {
      "id": "indigo",
      "name": "Indigo",
      "value": "http://example.org/indigo-seven.icc"
    }
  ]
}
```

### `colors`

The `colors` array is required.

Each color has the following attributes:

| Attribute | Type                                    | Required | Description                                                                                                                                                                                                                       |
| --------- | --------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`      | `string`                                | Yes      | The unique `id` of the color, which will be used internally by Lona Studio and in the generated code. This should be _code-friendly_: it must not contain spaces or unusual characters, since it will be used as a variable name. |
| `name`    | `string`                                | Yes      | The human-readable name of the color. This will be displayed in the Lona Studio UI. This will not appear in the generated code.                                                                                                   |
| `case`    | "color" or "themed" or "ref" or "group" | Yes      | The type of the color. Defines how the value should look like.                                                                                                                                                                    |
| `value`   | Depend on `case`                        | Yes      | An object representing the color. See [Color Value](#color-value) for more information about it.                                                                                                                                  |
| `comment` | `string`                                | No       | An optional description of the color, explaining contextual information, such as how it should be used. This may be displayed in the Lona Studio UI. This will not appear in the generated code.                                  |

### Color Value

The `value` of the color depends on its `case`.

#### `"color"`

A raw CSS 4 string representing the color, eg. `"#0000EE"` or `"rgba(255, 0, 0, 1)"` or `"color(indigo 0.0941 0.6274 0.3372 0.1647 0 0.0706 0.1216)"` if a color profile with the id `indigo` is defined.

See the [CSS specification](https://www.w3.org/TR/css-color-4/) for more information about the format of the string.

#### `"group`

An array of `Color`.

#### `"theme"`

The value of a color can also depend on the theme. To specify the value of the color for a specific theme, use the `id` of the theme as the property name. The property value is a raw CSS 4 string.

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
      "case": "themed",
      "value": {
        "light": "#000000",
        "dark": "#ffffff"
      }
    }
  ]
}
```

The value needs to specify its representation for all themes.

#### `"ref"`

It is possible for a value to reference another color's value by their `id` (a `string`) and extend it:

```json
// An identifier, for aliasing
"case": "ref",
"value": "baseColor"
```

When referencing a grouped color, the value needs to be the array of identifiers leading to the referenced color:

```json
// A member expression, for aliasing
"case": "ref",
"value": ["blues", "100"]
```

It is also possible to reference an expression representing a function call to extend an existing color.

For example, saturating a color:

```json
// A function call expression
"case": "ref",
"value": {
  "type": "call",
  "id": "saturate",
  "saturation": ["baseColor", "+", 0.2]
}
```

The functions are pre-defined. See https://www.w3.org/TR/2016/WD-css-color-4-20160705/#rgba-adjusters for more information about the functions available.

The first argument of each function is always a color reference, eg. either a reference to a color id or an expression of another function call.

### Color Type

Colors may be referenced from other files by their `id` (a `string`). Grouped color can be referenced by their "id path" (eg. `["colorId", "groupedColorId"]`). This helps us achieve a single source of truth for colors.

Colors may also appear _inline_ in other files (where a CSS color value is given directly), although this is discouraged for colors beyond `'black'`, `'white'`, and `'transparent'`.

## Sample File

`colors.json`

```json
{
  "colors": [
    {
      "id": "lonaTeal",
      "name": "Lona Teal",
      "case": "color",
      "value": "#008080",
      "comment": "Teal color for backgrounds"
    },
    {
      "id": "lonaBlue",
      "name": "Lona Blue",
      "case": "color",
      "value": "#000080",
      "comment": "Blue accent color"
    }
  ]
}
```
