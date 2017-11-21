# File Formats

> This specification may deviate slightly from what Lona actually uses. This specification is currently the _goal_.

Lona primarily operates on `.component` files. These are component definition files. Lona Studio manipulates these files, and Lona Compiler generates code from them.

The component format is defined here: [Component File Format](./component.md)

Lona additionally consumes a variety of other file formats for building design systems. Each of these is currently stored in a canonical location relative to the workspace.

|Type|Name|
|---|---|
|[Colors](./colors.md)|`colors.json`|
|[Text Styles](./text-styles.md)|`textStyles.json`|
|Gradients|`gradients.json`|
|Shadows|`shadows.json`|
|Types|`types.json`|