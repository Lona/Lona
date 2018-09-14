# Shadow Definitions

This file defines the design system's shadows.

### Specification

At the top level, the file is an object containing a `"shadows"` array and optionally a `"defaultShadowName"` string.

Each shadow within the `"shadows"` array has the following attributes:

|Attribute|Type|Required|Description|
|---|---|---|---|
|`id`|`string`|Yes|The unique `id` of the shadow, which will be used internally by Lona Studio and in the generated code. This should be _code-friendly_: it must not contain spaces or unusual characters, since it will be used as a variable name.|
|`name`|`string`|Yes|The human-readable name of the shadow. This will be displayed in the Lona Studio UI. This will not appear in the generated code.|
|`comment`|`string`|No|An optional description of the shadow, explaining contextual information, such as how it should be used. This may be displayed in the Lona Studio UI. This will not appear in the generated code. |
|`x`|`number`|No|The horizontal offset of the shadow, in pixel.|
|`y`|`number`|No|The vertical offset of the shadow, in pixel.|
|`blur`|`number`|No|The blur radius of the shadow, in pixels.|
|`color`|[`Color`](./colors.md#color-type)|No|The CSS color value or the `id` of the color defined in `colors.json`.|

The optional `"defaultShadowName"` determines the style of newly-created shadow within Lona Studio. This value should be the `id` of one of the shadows in the `"shadow"` array. This value will not be used in code.

### Sample File

`shadows.json`

```json
{
  "defaultShadowName": "elevation1",
  "shadows": [
    {
      "id": "elevation1",
      "name": "Elevation 1",
      "color": "black",
      "x": 0,
      "y": 2,
      "blur": 4
    },
    {
      "id": "elevation2",
      "name": "Elevation 2",
      "color": "red",
      "x": 0,
      "y": -2,
      "blur": 4
    },
    {
      "id": "elevation3",
      "name": "Elevation 3",
      "color": "yellow",
      "x": 0,
      "y": -4,
      "blur": 4
    }
  ]
}
```
