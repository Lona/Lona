# Component Definition

This file defines a UI component in the design system. Lona Studio is both a graphic design tool and an engineering tool, so some parts of the component definition only apply in some contexts, e.g. exporting images or generating code.

## Encoding

Currently component data is encoded in JSON.

JSON is problematic because it's not easily mergeable or human-editable. It could make sense to _store_ this data in a format that can be merged more easily (by humans or machines). The data would likely be _converted to JSON_ before consumed by any tool.

## Outline

The file is an object containing top-level fields:

- [**`metadata`**](#metadata)
- [**`devices`**](#devices)
- [**`examples`**](#examples)
- [**`params`**](#params)
- [**`root`**](#root)
- [**`logic`**](#logic)
- [**`private`**](#private)

## Metadata

Component metadata for documentation, indexing, and other miscellaneous purposes. This is an object containing the following optional fields:

|Attribute|Type|Required|Description|
|---|---|---|---|
|`tags`|`string[]`|No|An array of tags for categorizing/indexing the component|
|`description`|`string`|No|A description of the component, for documentation purposes. This field can contain markdown.|

### Sample

```json
// ...

"metadata": {
  "description": "My header component. Use it for displaying titles.",
  "tags": ["Header"]
}

// ...
```

## Devices

The various device sizes to render a component into within Lona Studio. These do not currently generate any code, although conceptually they could be useful for generating automated tests. This is an array of objects, where each object has the following fields:

|Attribute|Type|Required|Description|
|---|---|---|---|
|`name`|`string`|Yes|The human-readable name of the device.|
|`width`|`number`|Yes|The width the device.|
|`height`|`number`|Yes|The height of the device, in density-independent pixels.|
|`heightMode`|`'At Least' or 'Exactly'`|Yes|Should the device viewport grow beyond the specified height when filled with components? If `'At Least'`, the device viewport will grow. If `'Exactly'`, the device viewport will always be the exact `height` given, and components at the bottom will get clipped. |
|`visible`|`boolean`|Yes|This determines whether or not to draw this particular device on the screen.|
|`params`|`JSON`|Yes|This contains optional parameter values for use within [`Logic`](#logic).|
|`exportScale`|`number`|Yes|The scale to export artifacts. Defaults to `1` for `1x` resolution.|
|`backgroundColor`|[`Color`](./colors.md#color-type)|Yes|The device background color, displayed within Lona Studio and in exported artifacts.|

### Sample

```json
// ...

"devices": [
  {
    "name": "iPhone SE",
    "width" : 375,
    "height" : 100,
    "heightMode" : "At Least",
    "visible" : true,
    "params" : {},
    "exportScale" : 1,
    "backgroundColor" : "white"
  }
]

// ...
```

## Examples

These are the _examples_ or _test cases_ for a component. These do not currently generate any code, although conceptually they could be useful for generating automated tests. This is an array of objects, where each object has the following fields:

|Attribute|Type|Required|Description|
|---|---|---|---|
|`name`|`string`|Yes|The human-readable name of the example.|
|`type`|`'entry' or 'importedList'`|No|Is this an individual case defined explicitly, or a list of examples imported from JSON? Defaults to `entry`.|
|`visible`|`boolean`|No|This determines whether or not to draw this particular test case on the screen. Defaults to `true`.|
|`params`|`JSON`|No|This contains optional parameter values for use within [`Logic`](#logic). This will only be defined for examples with a `type` of `entry`.|
|`url`|`URL`|No|The URL of a list of examples defined in JSON. This will only be defined for examples with a `type` of `importedList`.|

### Sample

```json
// ...

"examples": [
  {
    "name" : "Default case",
    "params" : {
      "title" : "Header sample text"
    }
  }
]

// ...
```

## Params

|Attribute|Type|Required|Description|
|---|---|---|---|
|`name`|`string`|Yes|The code-friendly name of the parameter. This will be translated directly to a variable name, so it should not contain spaces or special characters.|
|`type`|`Data Type`|Yes|The data type of the parameter|
|`defaultValue`|`JSON`|No|The default value of the parameter. If specified, this will be used within code.|

```json
// ...

"params": [
  {
    "type" : "String",
    "name" : "title"
  },
  {
    "type" : "Boolean",
    "name" : "large",
    "defaultValue" : true
  }
]

// ...
```

## Root

This is the root of the layer hierarchy. Layers define the UI hierarchy. Each layer is an _instance_ of a component. The layer specifies which component it represents, and the params it will pass to that component. Layers may represent _built-in_ components or _custom_ components.

Layers contain the following attributes:

|Attribute|Type|Required|Description|
|---|---|---|---|
|`id`|`string`|Yes|The unique id of the layer, used as a key within logic.|
|`name`|`string`|Yes|The human-readable name of the layer. Naming the layer within Lona Studio updates the `id` field automatically by default.|
|`type`|`string`|Yes|For built-in components, the possible types are: `"Lona:View"`, `"Lona:Text"`, `"Lona:Image"`, `"Lona:Animation"`. Custom components have the same type as their filename, excluding the `.component` extension. There's also the special case, `"Lona:Children"`, which represents a placeholder for components which can be used within this component.|
|`params`|`JSON`|Yes|The input params for the specified component. For custom components, these are defined by the `params` attribute at the root level of the `.component` file for that component. For built-in types, these are defined below in this specification.|
|`children`|`Component[]`|No|The built-in `Lona:View` and `Lona:Image` components render children components within themselves. Custom components can render children by including the placeholder `Lona:Children` type within their `children` array.|

### Built-in Component Params

Coming soon!

## Logic

Coming soon!

### Private

This object contains information used internally by the UI of Lona Studio. Lona Studio will only write into keys prefixed by `"com.lonastudioapp"`. Lona Studio will leave other keys unaltered if they exist. In other words, external tools may write into this object and Lona Studio will not use or modify any keys. External tools should not use or modify any keys prefixed with `"com.lonastudioapp"`.

## Examples

Coming soon!
