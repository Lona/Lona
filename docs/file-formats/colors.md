# Color Definitions

This file defines the design system's colors.

### Specification

At the top level, the file is an object containing a `"colors"` array.

Each color has the following attributes:

| Attribute | Type     | Required | Description                                                                                                                                                                                                                       |
| --------- | -------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`      | `string` | Yes      | The unique `id` of the color, which will be used internally by Lona Studio and in the generated code. This should be _code-friendly_: it must not contain spaces or unusual characters, since it will be used as a variable name. |
| `name`    | `string` | Yes      | The human-readable name of the color. This will be displayed in the Lona Studio UI. This will not appear in the generated code.                                                                                                   |
| `value`   | `string` | Yes      | The color value, in CSS format. Any valid CSS value is valid here: e.g. `blue`, `fce`, `#ffccee`, `rgb(0,0,100)`, `rgba(255,255,255,0.3)`                                                                                         |
| `comment` | `string` | No       | An optional description of the color, explaining contextual information, such as how it should be used. This may be displayed in the Lona Studio UI. This will not appear in the generated code.                                  |

### Color Type

Colors may be referenced from other files by their `id` (a `string`). This helps us achieve a single source of truth for colors.

Colors may also appear _inline_ in other files (where a CSS color value is given directly), although this is discouraged for colors beyond `'black'`, `'white'`, and `'transparent'`.

### Sample File

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
