# Lona Compiler

The Lona Compiler is a CLI tool for generating cross-platform UI code from JSON definitions.

The Lona Compiler is published on `npm` as `lonac` -- however, this is likely outdated. You should build the development version for now.

## Development

This project is written in ReasonML, an OCaml dialect that can compile to JavaScript using BuckleScript.

### Setup

#### 1. Install ReasonML

Install from: [https://reasonml.github.io/docs/en/installation](https://reasonml.github.io/docs/en/installation)

#### 2. Install dependencies with yarn

From this directory, run:

```
yarn
```

> Note: If you don't have yarn installed already, you can download it with npm: `npm install --global yarn`

#### 3. Install a ReasonML plugin for your text editor

I recommend developing with VSCode and the `reason-vscode` plugin (there are several plugins, but this one is most reliable in my experience).

### Build + Watch

```
yarn start
```

### Commands

There are currently 3 commands:

* `colors` - Generate colors code from a `colors.json` file
* `component` - Generate component code from a `.component` file
* `workspace` - Generate a directory with code for colors, text styles, and every `.component` file in a directory

For each command, you'll choose a code generation `target`: `swift`, `js`, or `xml`.

You can specify a framework using the `--framework=...` option.

In the case of `js`, the options are:

* `reactnative`: [React Native](https://facebook.github.io/react-native/) (default)
* `reactdom`: [React DOM](https://reactjs.org)
* `reactsketchapp`: [React SketchApp](http://airbnb.io/react-sketchapp/)

In the case of `swift`, the options are:

* `uikit`: iOS
* `appkit`: macOS

Check out the scripts section of the `package.json` to see some examples. There is a `snapshot` command for each compiler target.

### Generate colors

This will output the generated colors code to `stdout`. You may also pass the `colors.json` file through `stdin` instead of as a parameter, if you prefer.

```bash
lonac colors [target] [path-to-colors.json]
```

### Generate component

The will output the generated component code to `stdout`.

```
lonac component [target] [path-to-component.component]
```

### Generate workspace

This will generate the colors, text styles, and all components, writing them to `output-directory` in the same structure as the input workspace directory.

```
lonac workspace [target] [path-to-workspace] [output-directory]
```
