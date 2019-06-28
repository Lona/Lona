# Lona Compiler

The Lona Compiler is a CLI tool for generating cross-platform UI code from JSON definitions.

The Lona Compiler is published on `npm` as `lonac`.

## Usage

### Installation

First, install the compiler with:

```bash
npm install --global lonac
```

You may also install locally to your current project if you prefer, by removing the `--global`.

### Commands

For each command, you'll choose a code generation `target`: `swift`, `js`, or `xml`.

You can specify a framework using the `--framework=...` option.

In the case of `js`, the options are:

- `reactnative`: [React Native](https://facebook.github.io/react-native/) (default)
- `reactdom`: [React DOM](https://reactjs.org)
- `reactsketchapp`: [React SketchApp](http://airbnb.io/react-sketchapp/)

In the case of `swift`, the options are:

- `uikit`: iOS
- `appkit`: macOS

### Examples

Here are a handful of examples. You can check out the scripts section of the `package.json` to see more targets/frameworks -- there is a `snapshot` command for each compiler target.

#### Generate workspace

This will generate the colors, text styles, shadows, custom types, and all components, writing them to `output-directory` in the same structure as the input workspace directory.

```bash
lonac workspace --target js --workspace [path-to-workspace-directory] --output [output-directory]
```

#### Generate colors

This will output the generated colors code to `stdout`. You may also pass the `colors.json` file through `stdin` instead of as a parameter, if you prefer.

```bash
lonac colors --target js --input [path-to-colors.json]
```

#### Generate component

The will output the generated component code to `stdout`.

```bash
lonac component --target js --input [path-to-colors.json]
```

## Contributing

To build the compiler from source, follow these steps.

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

### Running commands

The above examples can now be run by replacing `lonac` with `node src/main.bs.js`.
