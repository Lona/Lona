## Vector Graphics support

Lona supports SVG files on every platform. To use an SVG in your components, add a layer with the `VectorGraphic` layer type in Lona Studio.

![VectorGraphic layer](https://i.imgur.com/huYX1EX.png)

You can choose which SVG file this layer uses in the inspector under the "Image" section.

![Image chooser](https://i.imgur.com/Gbsp593.png)

You must currently choose a file on your computer (not a remote url), and you should make sure the file is located somewhere within your workspace directory (but can be in a subdirectory, e.g. `assets`).

You'll also currently need to have _built the Lona compiler_. In Lona Studio preferences, you must set the compiler path manually to the `main.bs.js` file of the compiler.

> The preferences screen is slightly buggy, so you may need to choose the `Some` dropdown twice.

![Compiler path](https://i.imgur.com/a0RnVwp.png)

### How it works

Lona Studio analyzes your SVG file and lets you assign parameters to individual path parameters, e.g. the stroke and fill of a specific path. Assigning to path parameters is currently only possible in Lona Logic. You can find the path parameters under `layers -> MyVectorGraphic -> vector`.

The Lona compiler then converts each `VectorGraphic` layer into an appropriate format for the platform. The conversion is as follows:

- React DOM: Standard `<svg>` tags
- React Native: The `Svg` component from `react-native-svg` (https://github.com/react-native-community/react-native-svg)
- React Sketchapp: The `Svg` component from `react-sketchapp`
- iOS: CoreGraphics drawing commands
- AppKit: CoreGraphics drawing commands

### Limitations

Because the Lona compiler converts SVG files into a different format _at compile time_, every `VectorGraphic` layer _must_ reference a single SVG file -- you can't have a `VectorGraphic` layer that accepts an SVG as a parameter, and you can't have a `VectorGraphic` layer with no underlying SVG file.
