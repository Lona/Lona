# Lona Compiler

The Lona Compiler is a CLI tool for generating cross-platform UI code from JSON definitions.

## Usage

### Installation

To use in a JavaScript project:

```bash
npm install --save-dev lonac
```

Or

```bash
yarn add --dev lonac
```

Then you'll be able to access the `lonac` executable either through `package.json` scripts, or as `./node_modules/.bin/lonac`.

### Commands

There are currently 3 commands:

* `colors` - Generate colors code from a `colors.json` file
* `component` - Generate component code from a `.component` file
* `workspace` - Generate a directory with code for colors, text styles, and every `.component` file in a directory

For each command, you'll choose a code generation `target`: `swift`, `js`, or `xml`.

In the case of `js`, you can also specify a framework using the `--framework=...` option:

* `reactnative`: [React Native](https://facebook.github.io/react-native/) (default)
* `reactdom`: [React DOM](https://reactjs.org)
* `reactsketchapp`: [React SketchApp](http://airbnb.io/react-sketchapp/)

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

## Development

This project is written in ReasonML, an OCaml dialect that can compile to JavaScript using BuckleScript.

### Setup

#### 1. Install ReasonML

Install from: https://reasonml.github.io/docs/en/global-installation.html

#### 2. Install dependencies with yarn

From this directory, run:

```
yarn
```

> Note: If you don't have yarn installed already, you can download it with npm: `npm install --global yarn`

#### 3. Install a ReasonML plugin for your text editor

I recommend developing with VSCode

### Build + Watch

```
yarn watch
```
