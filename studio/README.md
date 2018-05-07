## Installation

The easiest way to use Lona Studio is by downloading the prebuilt Mac App binary... but we're not distributing this until Lona Studio becomes more stable.

## Building from Source

First, make sure you have [`bundler`](http://bundler.io/) and [Cocoapods](https://cocoapods.org/) installed. Then checkout the repo and run:

```
cd studio
bundle && bundle exec pod install
```

Open LonaStudio.xcworkspace and build in Xcode 9.3+ on High Sierra+. If there are warnings (e.g. about project settings) you can ignore them.

## Workspace

To work in Lona Studio, you'll need a properly configured _workspace_. A workspace is a directory containing, optionally, the following files:

* `colors.json`
* `textStyles.json`
* `gradients.json`
* `shadows.json`
* `types.json`

Opening the material design directory in the `examples` directory is a good place to start.

You can read more about these in the [file formats docs](./docs/file-formats/README.md). Without these, Lona Studio will not display any colors or text styles in the pickers.

To set your workspace directory, first open Lona Studio preferences:

![Open Preferences](../docs/images/open-preferences.png)

Then choose a directory path:

![Set Workspace Path](../docs/images/set-workspace-path.png)
