<p align="center">
  <img src="studio/LonaStudio/Assets.xcassets/AppIcon.appiconset/icon_256x256@2x.png" width="256" height="256" />
</p>

<h1 align="center">Lona (Developer Preview)</h1>

<br />

> This project is still in a _very early_ stage. We don't provide any support of any kind. You shouldn't use this for production unless you _really know what you're doing_. The API and file format may change without warning as we continue development. There are no automated tests and the code is not yet at the same degree of technical rigor as other Airbnb projects.
>
> Want to get involved? Open a GitHub issue or say hello on Twitter! [@dvnabbott](https://twitter.com/dvnabbott)

## Overview

[![Build Status](https://travis-ci.org/airbnb/Lona.svg?branch=master)](https://travis-ci.org/airbnb/Lona)

Lona is a collection of tools for building design systems and using them to generate cross-platform UI code, Sketch files, and other artifacts.

Lona consists primarily of 3 parts:

* [Lona Components](#lona-components) - A data format, `.component`, for cross-platform components
* [Lona Studio](#lona-studio) - A GUI tool for designing `.component` files
* [Lona Compiler](#lona-compiler) - A CLI tool & API for for generating UI code from `.component` files

### Lona Components

A design system is defined in JSON as a collection of:

* Components (can be nested)
* Colors, Text Styles, Gradients, and Shadows
* Data Types

The specification for these files can be found in the [docs](./docs/file-formats/README.md).

### Lona Studio

Lona Studio provides a graphical interface for working with `.component` files.

Lona Studio is primarily for building component systems, but can also be used for:

* Quickly mocking up new screens from existing components
* Viewing designs with real data from JSON files or APIs
* Experimenting with designs across multiple screen sizes
* Automating design tasks - e.g. localizing screenshots for different languages and exporting hundreds of images
* Working with animations (Lottie) and rendering videos from them
* and more!

If you have Xcode installed, you can try it out by following the [installation instructions](./studio/README.md).

> Wondering if this replaces Sketch? Why a native Mac App? I answer some common questions here in the [FAQ](./docs/overview/faq.md).

### Lona Compiler

Lona Compiler converts .component files to UI code for various targets.

Support is planned for:

* iOS / macOS (Swift)
* Android (Kotlin)
* React (JavaScript)

Currently, the only functioning target is Swift, and it's extremely rough. If you still want to try it out, check out the [installation instructions](./compiler/core/README.md).

## The Team

* Created by [@dvnabbott](https://twitter.com/dvnabbott)
* Design & development help by [@ryngonzalez](https://twitter.com/ryngonzalez)
* Gorgeous logo by [@pablocar0](https://twitter.com/pablocar0)
* Lona Studio development by [Nghia Tran](https://github.com/NghiaTranUIT)
* Swift code generation help by [Laura Skelton](https://twitter.com/skelovenko)
* Lona Compiler development by [Jason Zurita](https://twitter.com/jasonalexzurita)
