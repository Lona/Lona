# Color Definitions

This file defines the design system's colors.

The file is an object, containing a `"colors"` array.

Each color has the following attributes:

|Attribute|Required|Description|
|---|---|---|
|`id`|Yes|The unique `id` of the color, which will be used internally by Lona Studio and in the generated code. This should be _code-friendly_: it must not contain spaces or unusual characters, since it will be used as a variable name.|
|`name`|Yes|The human-readable name of the color. This will be displayed in the Lona Studio UI. This will not appear in the generated code.|
|`value`|Yes|The color value, in CSS format. Any valid CSS value is valid here: e.g. `blue`, `fce`, `#ffccee`, `rgb(0,0,100)`, `rgba(255,255,255,0.3)`|
|`value`|No|The color value, in CSS format. Any valid CSS value is valid here: e.g. `blue`, `fce`, `#ffccee`, `rgb(0,0,100)`, `rgba(255,255,255,0.3)`|

### Sample File

`cscolors.json`

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