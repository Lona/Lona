<p align="center">
  <img src="ComponentStudio/Assets.xcassets/AppIcon.appiconset/icon_256x256@2x.png" width="256" height="256" />
</p>

<h1 align="center">Component Studio (Developer Preview)</h1>

<br />

> This is a *highly experimental* project. We've made it public to begin getting feedback and working with collaborators from other companies who are interested in design at scale. While this tool handles the Airbnb design system fairly well, there are many gaps. We hope to work with other companies to identify and fill these gaps.
> We don't provide any support of any kind. You shouldn't use it for production. The API and file format will change rapidly as we continue development.

## Overview

Component Studio is a tool for building design systems and using them to generate cross-platform UI code, Sketch files, images, and other artifacts.

A design system is defined in JSON as a collection of:
- Colors, Gradients, and Shadows
- Text Styles
- Components (can be nested)

Component Studio provides a graphical interface for working with these JSON files. 

Component Studio is useful for:
- Generating UI code from designs
- Quickly mocking up new screens from existing components
- Viewing designs with real data from JSON files or APIs
- Experimenting with designs across multiple screen sizes
- Automating design tasks - e.g. localizing screenshots for different languages and exporting hundreds of images
- Working with animations (Lottie) and rendering videos from them (can plug into distributed renderer API)
- and more!

## Background

### The Problem

Airbnb created a design system called [DLS](https://airbnb.design/building-a-visual-language/), used across web, iOS, Android, and React Native. This system helps ensure cross-platform consistency across the Airbnb product line.

This design system was defined in Sketch. Design files required manual translation to code for each of the 4 platforms. This translation process was time consuming and error prone. The fundamental problem: most design file formats can't encode all of the necessary details needed to make a perfect translation.

We need a tool for dealing with the layouts, constraints, and states of a real application:
- Layout reflow for multiple screen sizes
- Variable-length text
- Error states
- Lists of different kinds and quantities of items: 0, 1, 2, 10…
- Min and max width/height
- Max lines of text
- Pressed/unpressed state
- Themes (inverse, compact)

Since many decisions must be made that can't be recorded in design files, the individual engineer on each platform often makes a judgement call, resulting in subtle inconsistencies.

### The Solution

What if we had a single design system specification that encodes *all* of the detail needed to accurately translate from design to code? This spec would act as the source of truth. An engineer could then write code which captures the design with *100% accuracy*. If the design file is missing a key piece of information, the designer and engineer could work together to add it to the source of truth.

If an engineer can manually translate this file format into UI code with 100% accuracy, then fundamentally we should also be able to use this file format to generate the UI code.

Component Studio enables us to build this design system specification graphically.

Component Studio stores `.component` files. Separately, we've written command-line tools for converting `.component` files to UI code for each platform. The reference implementations are available in the `generators` directory. We encourage companies to fork the generators to suit their own development stack.

Component Studio isn't intended to replace your existing design tools, but rather augment them. Current design tools are extremely powerful when it comes to creating and iterating on new ideas. However, after new ideas have been designed, they need to be stress tested on different screen sizes and with real data. They then need to be translated into UI code. This is where Component Studio shines.

## Installation

The easiest way to use Component Studio is by downloading the prebuilt Mac App binary... but we're not distributing this until Component Studio becomes more stable.

## Building from Source

First, make sure you have Cocoapods installed. Then checkout the repo and run:

`pod install`

Build in Xcode 9 on Sierra+. If there are warnings (e.g. about converting to Swift 4) you can ignore them.

It will build on El Capitan, but it likely won't be usable. The changes needed to make are small, if anybody wants to add support.

## Generating Code

### React Native & React Primitives Code

> Very very experimental. Likely won't generate usable code in its current state

Run the script in `generators/react` on a component studio workspace, e.g:

`node index.js [my_workspace_path] output`

This script will convert every `.component` file in the workspace, maintaining the directory structure. It will also copy over colors, typography, and other workspace settings, converting them into a better format for usage in code.

Usage instructions:

```
  Usage: index [options] <workspace> <output-dir>


  Options:

    -V, --version        output the version number
    --primitives         Import React components from "react-primitives"
    --filter [optional]  Filter the component files to convert by regex
    -h, --help           output usage information
```

## FAQ

(Answered in first person by [@devinaabbott](https://twitter.com/devinaabbott))

### Why a native Mac app rather than Electron?

While Electron is fantastic for cross-platform desktop apps, building cross-platform adds a lot of engineering overhead. Airbnb designers and engineers all work on Macs, so we can move much faster by focusing only on the Mac platform.

As an example of how building native helps us move quickly: native code has a much higher threshold before performance becomes a serious issue. In my experience building Deco IDE using Electron, performance was an issue I had to address frequently -- it was always solvable, but definitely required time and effort. So far, Component Studio performance has been mostly fine without any optimizations. The app gets slow with hundreds of canvases, but that's not the core use case at the moment, and I'm sure it can be solved with effort.

As an added bonus, it's also much easier to interop with Sketch. For example, Sketch stores some text styles as encoded `NSAttributedString` objects. Component Studio is able to read and write these directly. It would be difficult to do so in a non-Mac environment.

### How does the layout algorithm work?

Component Studio uses flexbox with [Yoga](https://github.com/facebook/yoga) under the hood. The tool applies one major simplification: it automatically handles switching certain properties (`align-items`, `justify-content`, and `flex`) based on `flex-direction`, so you don't have to.

### Why is this Swift code so weird/bad?

This is my first time writing a native mac app, and I have practically no Swift experience. The blame entirely falls on me for this. Contributions are welcome!

### Will it do X?

Most likely. If there's a design system that needs it, Component Studio should support it. Want to help add it?

## The Team

- Created by [@devinaabbott](https://twitter.com/devinaabbott)
- Coding & design help by [@ryngonzalez](https://twitter.com/ryngonzalez)
- Gorgeous logo by [@pablocar0](https://twitter.com/pablocar0)
