# Component Definitions

This file defines a UI component in the design system. Lona Studio is both a graphic design tool and an engineering tool, so some parts of the component definition only apply in some contexts, e.g. exporting images or generating code.

The file is an object containing 6 top-level fields:

- [**`metadata`**](#metadata)
- [**`canvases`**](#canvases)
- [**`cases`**](#cases)
- [**`parameters`**](#parameters)
- [**`rootLayer`**](#rootLayer)
- [**`logic`**](#logic)
- [**`config`**](#config)

## Metadata

Component metadata for documentation, indexing, and other miscellaneous purposes. This is an object containing the following optional fields:

|Attribute|Type|Required|Description|
|---|---|---|---|
|`tags`|`string[]`|No|An array of tags for categorizing/indexing the component|
|`name`|`string`|No|A description of the component, for documentation purposes. This field can contain markdown.|

## Canvases

The various canvases sizes to render a component within Lona Studio. These do not currently generate any code, although conceptually they could be useful for generating automated tests. This is an array of objects, where each object has the following fields:

|Attribute|Type|Required|Description|
|---|---|---|---|
|`name`|`string`|Yes|The human-readable name of the canvas.|
|`width`|`number`|Yes|The width the canvas.|
|`height`|`number`|Yes|The height of the canvas, in density-independent pixels.|
|`heightMode`|`'At Least' or 'Exactly'`|Yes|Should the canvas grow beyond the specified height when filled with components? If `'At Least'`, the canvas will grow. If `'Exactly'`, the canvas will always be the exact `height` given, and components at the bottom will get clipped. |
|`exportScale`|`number`|Yes|The scale to export artifacts. Defaults to `1` for `1x` resolution.|
|`backgroundColor`|[`Color`](./colors.md#color-type)|Yes|The canvas background color, displayed within Lona Studio and in exported artifacts.|
|`visible`|`boolean`|Yes|This determines whether or not to draw this particular canvas on the screen.|
|`parameters`|`JSON`|Yes|This contains optional parameter values for use within [`Logic`](#logic).|

## Cases

These are the _use cases_ or _test cases_ for a component. These do not currently generate any code, although conceptually they could be useful for generating automated tests. This is an array of objects, where each object has the following fields:

|Attribute|Type|Required|Description|
|---|---|---|---|
|`name`|`string`|Yes|The human-readable name of the test case.|
|`type`|`'entry' or 'importedList'`|Yes|Is this an individual case defined explicitly, or a list of cases imported from JSON?|
|`visible`|`boolean`|Yes|This determines whether or not to draw this particular test case on the screen.|
|`parameters`|`JSON`|No|This contains optional parameter values for use within [`Logic`](#logic). This will only be defined for cases with a `type` of `entry`.|
|`url`|`URL`|No|The URL of a list of cases defined in JSON. This will only be defined for cases with a `type` of `importedList`.|

### Sample File

`Header.json`

```json
{
  "metadata": {},
  "canvases": [],
  "cases": [],
  "parameters": [],
  "rootLayer": {},
  "logic": [],
  "config": {}
}
```