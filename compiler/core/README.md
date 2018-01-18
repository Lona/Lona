# Lona Compiler

_This is very experimental! Don't use it unless you know what you're doing!_

## Setup

This project is written in ReasonML, an OCaml dialect that can compile to JavaScript using BuckleScript.

### Install

Install with yarn. _(If you don't have yarn installed already, you can download it with npm: `npm install --global yarn`)_

From this directory, run:

```
yarn
```

### Build

```
npm run build
```

### Build + Watch

```
npm run watch
```

## Running

* **`target`** - One of: `swift`, `js`

### Generate colors

The will output the generated colors code to stdout.

```
node src/demo.bs.js colors [target] [path-to-colors.json]
```

### Generate component

The will output the generated component code to stdout.

```
node src/demo.bs.js component [target] [path-to-component.component]
```

### Generate workspace

This will generate the colors file and all components, writing them to `output-directory`, matching the directory structure of the workspace.

```
node src/demo.bs.js workspace [target] [path-to-workspace] [output-directory]
```
