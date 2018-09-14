# Text Style Definitions

This file defines the design system's text styles.

### Specification

At the top level, the file is an object containing a `"styles"` array and optionally a `"defaultStyleName"` string.

Each text style within the `"styles"` array has the following attributes:

|Attribute|Type|Required|Description|
|---|---|---|---|
|`id`|`string`|Yes|The unique `id` of the text style, which will be used internally by Lona Studio and in the generated code. This should be _code-friendly_: it must not contain spaces or unusual characters, since it will be used as a variable name.|
|`name`|`string`|Yes|The human-readable name of the text style. This will be displayed in the Lona Studio UI. This will not appear in the generated code.|
|`comment`|`string`|No|An optional description of the text style, explaining contextual information, such as how it should be used. This may be displayed in the Lona Studio UI. This will not appear in the generated code. |
|`fontName`|`string`|No|The name of the font.|
|`fontFamily`|`string`|No|The name of the font family.|
|`fontWeight`|`string`|No|The weight of the font, in CSS values: a string in increments of 100, from 100 to 900.|
|`fontSize`|`number`|No|The size of the font, in pixels.|
|`lineHeight`|`number`|No|The height of each line of text, in pixels.|
|`letterSpacing`|`number`|No|Uniformly adjust the spacing between each character. A positive number indicates more space, while a negative number indicates less space.|
|`color`|[`Color`](./colors.md#color-type)|No|The CSS color value or the `id` of the color defined in `colors.json`.|
|`extends`|`string`|No|The `id` of the another text style to extend.|

The optional `"defaultStyleName"` determines the style of newly-created text within Lona Studio. This value should be the `id` of one of the text styles in the `"styles"` array. This value will not be used in code.

### Sample File

`textStyles.json`

```json
{
  "defaultStyleName": "h2",
  "styles": [
    {
      "id": "h1",
      "name": "Heading 1",
      "fontFamily": "Helvetica Neue",
      "fontWeight": "300",
      "fontSize": 48,
      "lineHeight": 56,
      "letterSpacing": -0.3,
      "color": "lonaBlue"
    },
    {
      "id": "h2",
      "name": "Heading 2",
      "fontFamily": "Helvetica Neue",
      "fontWeight": "500",
      "fontSize": 32,
      "lineHeight": 40,
      "letterSpacing": -0.3,
      "color": "rgba(0,0,0,0.9)"
    }
  ]
}
```
