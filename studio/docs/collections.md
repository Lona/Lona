## Using Lona-generated components in collection views

For a reference implementation of using Lona-generated components in a collection view, see the _very alpha not-ready-to-be-used_ [LonaCollectionView](https://github.com/airbnb/Lona/blob/master/examples/generated/test/swift/LonaCollectionView.swift). This collection view integrates specifically with subclasses of `LonaControlView` to provide snappier tap callbacks and highlight states. About half of this file is hardcoded, and half is generated -- Lona automatically generates a UICollectionViewCell subclass for each component, and a bunch of boilerplate for wiring them up.

> The `LonaCollectionView` can be generated for your project by using the `--generateCollectionView=1` compiler flag -- but I don't recommend using it yet, since it's very likely to change and still has some quirks.

If the root layer of a component has a tap callback parameter, you may use either this parameter or the collection view's delegate method:

```swift
public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
```

To use the delegate method however, you'll need to disable the component by setting `isEnabled` to `false`. The reference implementation calls the tap callback from within this delegate method, for convenience.

Another important special/edge case:

- if you make the root layer of a component interactive
- and the component contains a _nested_ interactive layer

then Lona generates the component slightly differently in order to work better in collections. Lona will add a custom `hitTest` function and `isRootControlTrackingEnabled` variable ([see here](https://github.com/airbnb/Lona/blob/dc8d6e39bf43756424a5f2e8a4a6568ac44620a9/examples/generated/test/swift/interactivity/PressableRootView.swift#L145-L152)). These can then optionally be [configured by the collection view](https://github.com/airbnb/Lona/blob/master/examples/generated/test/swift/LonaCollectionView.swift#L307).

There are a lot of little edge cases to consider to acheive an optimal UX, and I'm still figuring out the best way to work with collection views. So far, the reference implementation works well in most cases though.

> Note: Components become interactive when they have a `pressed`, `hovered`, or `onPress` parameter set in Lona Studio
