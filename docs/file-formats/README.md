# File Formats

Lona primarily operates on `.component` files. These are component definition files. Lona Studio manipulates these files, and Lona Compiler generates code from them.

The component format is defined here: [Component File Format](./components.md)

Lona additionally consumes a variety of other file formats for building design systems. Each of these is currently stored in a canonical location relative to the workspace.

|Type|Name|
|---|---|
|[Colors](./colors.md)|`cscolors.json`|
|[Text Styles](./text-styles.md)|`cstypography.json`|
|[Gradients](./gradients.md)|`csgradients.json`|
|[Shadows](./shadows.md)|`csshadows.json`|
|[Types](./types.md)|`cstypes.json`|