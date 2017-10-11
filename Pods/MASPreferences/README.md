# MASPreferences

This component is intended as a replacement for SS_PrefsController by Matt Legend Gemmell and Selectable Toolbar by Brandon Walkin. It is designed to use NSViewController subclasses for preference panes.

# How to use

You can find a Demo project at [MASPreferencesDemo](https://github.com/shpakovski/MASPreferencesDemo).

##Swift Edge case
When using Swift you need to override the `identifier` from `MASPreferencesViewController` the following to be compatible with the mutable identifier `String?` in `NSViewController`

    override var identifier: String? { get {return "general"} set { super.identifier = newValue} }
