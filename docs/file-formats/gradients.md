# Gradient Definitions

This file defines the design system's gradients.

### Specification

At the top level, the file is an object containing a `"gradients"` array.

Each gradient within the `"gradients"` array has the following attributes:

|Attribute|Type|Required|Description|
|---|---|---|---|
|`id`|`string`|Yes|The unique `id` of the gradient, which will be used internally by Lona Studio and in the generated code. This should be _code-friendly_: it must not contain spaces or unusual characters, since it will be used as a variable name.|
|`name`|`string`|Yes|The human-readable name of the gradient. This will be displayed in the Lona Studio UI. This will not appear in the generated code.|
|`comment`|`string`|No|An optional description of the gradient, explaining contextual information, such as how it should be used. This may be displayed in the Lona Studio UI. This will not appear in the generated code. |
|`colorStops`|`Array<{ position: number, color: Color }>`|Yes|The stops of the gradient.|

### Sample File

`gradients.json`

```json
{
  "gradients": [
    {
      "id": "gradient1",
      "name": "Gradient 1",
      "colorStops": [
        {
          "position": 0,
          "color": "black"
        },
        {
          "position": 1,
          "color": "white"
        }
      ]
    }
  ]
}
```
