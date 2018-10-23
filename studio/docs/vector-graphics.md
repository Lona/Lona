## Vector Graphics support

Lona supports SVG files on every platform. To use an SVG in your components, add a layer with the `VectorGraphic` layer type in Lona Studio.

![VectorGraphic layer](https://i.imgur.com/huYX1EX.png)

You can choose which SVG file this layer uses in the inspector under the "Image" section.

![Image chooser](https://i.imgur.com/Gbsp593.png)

You must currently choose a file on your computer (not a remote url), and you should make sure the file is located somewhere within your workspace directory (but can be in a subdirectory, e.g. `assets`).

You'll also currently need to have _built the Lona compiler_. In Lona Studio preferences, you must set the compiler path manually to the `main.bs.js` file of the compiler.

> The preferences screen is slightly buggy, so you may need to choose the `Some` dropdown twice.

![Compiler path](https://i.imgur.com/4SydQUL.png)

### How it works

Lona Studio analyzes your SVG file and lets you override individual element parameters, e.g. the stroke and fill of a specific path. Assigning to element parameters is currently only possible in Lona Logic. You can find the element parameters under `layers -> MyVectorGraphic -> vector`. Overriding parameters is optional. Lona will default to the parameters in the SVG file.

The Lona compiler then converts each `VectorGraphic` layer into an appropriate format for the platform. The conversion is as follows:

- React DOM: Standard `<svg>` tags
- React Native: The `Svg` component from `react-native-svg` (https://github.com/react-native-community/react-native-svg)
- React Sketchapp: The `Svg` component from `react-sketchapp`
- iOS: CoreGraphics drawing commands
- AppKit: CoreGraphics drawing commands

### Recommendations

#### SVG element naming

It's best to name your SVG elements before using them in Lona Studio. Lona references specific elements by their `id` attribute if one exists. Using an `id` will allow you to change the underlying SVG file more easily without requiring any changes in Lona Studio.

Design tools like Sketch should automatically assign the `id` based on layer name when you export to SVG. For example:

![Vector layer name](https://i.imgur.com/roErAHO.png)

This will allow you to assign `layers -> MyVectorGraphic -> vector -> contents -> fill` to change the `fill` color of the `contents` layer.

With no `id` available, Lona falls back to the element's "path", e.g. group1.rect0, to uniquely identify the element.

> If you change the `id` of an element referenced by Logic, the Lona Compiler will _fail or generate incorrect code_ unless you also update the corresponding Logic statements.

### Limitations

Because the Lona compiler converts SVG files into a different format _at compile time_, every `VectorGraphic` layer _must_ reference a single SVG file -- you can't have a `VectorGraphic` layer that accepts an SVG as a parameter, and you can't have a `VectorGraphic` layer without an underlying SVG file.
