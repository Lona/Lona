# workspace-to-sketch-library

Generate a Sketch library from a Lona Workspace.

## Installation

```bash
npm install @lona/workspace-to-sketch-library lonac
```

## Usage

```js
const generateLibrary = require('@lona/workspace-to-sketch-library')

generateLibrary(workspacePath, outputPath, options)
```

All options are optional.

- `options.compiler`: path to the Lona compiler to use (will default to the installed `lonac` compiler's path)
- `options.devicePresetList`: array of device presets (`{ name, width, height }`)
- `options.componentPathFilter`: function that returns a boolean depending on whether a component should be included in the library or not. It receives the path to the component as argument
- `options.logFunction`: a function to log the progress (typically, `console.log`)
