## Performance of Lona-generated components

When it comes to improving performance, the first place to look is Lona Studio. Any improvements made here should be pretty low-effort, and will likely improve performance for every platform. After that, there are some incremental improvements you can make on each platform.

- [Lona Studio](#lona-studio)
- [Swift](#swift)
- [JavaScript](#javascript)

### Lona Studio

#### Rendering less

The best way to improve performance is to _render less_. Try to use the minimum number of layers possible to create your UI.

- Are there extra wrapper `View`s that can be removed? If a view is used _only_ for layout and _only_ has a single child, it's possible it can be removed. Can you instead put its padding as the margin of its child?
- Are there layers that are permanently hidden? If a layer is _never_ visible, just delete. These may affect the performance of the generated UI.

#### Improving component boundaries

Components only re-render when their parameters change. Based on the specifics of your components, you may be able to break them down into smaller parts that don't need to re-render as frequently.

- If you have a monolithic component with a lot of layers, consider if there's a more optimal way to break it down into smaller components. Changing a single parameter of a large component may have a relatively high performance cost since it re-renders a lot of layers. If there's a smaller portion of this UI that rarely changes, that's a good candidate for a new component. You can then pass the parameters from the larger component into the smaller one.
- If your component is used within a list/collection view, it may be instantiated and configured at separate times. If there's a specific configuring that's particularly common in your UI, consider making this the initial state of the component. Then most of the work will be done when the component is instantiated.

### Swift

The best way to improve performance is to reduce the number of `UIView`s used -- this means using fewer layers in Lona Studio. Assuming you've already tried to reduce the number of layers, here are a few (new) optimizations you can consider.

#### Parameters

Any time a parameter changes, the `update()` function runs the component's logic, updating the UI based on its parameters. Setting parameters individually may cause `update()` to run multiple times. It's best to set them all at once by creating/modifying a `Parameters` struct and assigning it to the component's `parameters` member variable.

Lona adds a layer of indirection between _function_ parameters and logic -- this allows the component to always call the latest function passed, without having to re-run the component's logic. Therefore, changing a function parameter will _never_ call `update()`, since in most cases a function can't affect the UI. There will be a way to opt out of this in edge cases (and call `update()` on changes), but that doesn't exist yet.

> Note that `Parameters` is `Equatable`... but that's a little misleading, since function parameters can't actually be compared for equality (Swift doesn't support this). I'm considering removing `Equatable`, and instead providing a method for comparing the non-function contents of 2 `Parameters` structs.

#### Tables & Collections

Components are designed to work well in tables and collections, so if they don't, let me know!

For achieving snappy tap/highlight states in collections, see this [guide](./collections.md).

#### Code size

Most of the time, code size shouldn't be a huge concern, since these components aren't intended to be modified by hand. However, there can be cases where you'll want to move a file out of the generated directory and modify a portion by hand, or where the code size simply gets out of hand. Here are a couple things you can do:

- Consider splitting a large component into smaller ones. This won't reduce the total amount of code, but it'll be in more manageable portions.
- Reduce the amount of _conditional_ constraints. When a component hides/shows a view depending on its parameters, Lona generates a set of constraints that will only be activated when the view is visible. Lona generates every permutation of which conditional constraints need to be activated, deciding at runtime which set to use based on which views are visible. This takes a lot of code: it's N², where N is the number of views that are sometimes hidden. Instead of hiding a lot of separate views, consider using a wrapper view and instead hiding/showing that. This will reduce N, reducing the total lines of code generated. A wrapper view will hurt rendering performance though, so use sparingly. Splitting a large component into smaller ones can also improve this.

### JavaScript

Coming soon...
