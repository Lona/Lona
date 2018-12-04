## Enums (Variants)

Enum types, also sometimes called Variants throughout Lona, are great for representing mutually exclusive component parameters. For example, a button might be in a "normal", "success", or "error" state, but it can only be in one at a time. This is a good opportunity to use an Enum type.

Lona Studio can model Enum types in 2 ways: globally to the workspace, and locally to a component.

Note that Enum's can contain _data_ (i.e. algebraic data types), but that this may not currently generate valid code, so it's not recommended.

- [Global enums](#global-enums)
- [Component-local enums](#component-local-enums)

### Global enums

Enums can be defined in a `types.json` file in the root of the workspace. For example:

```json
{
  "types": [
    {
      "alias": "ButtonType",
      "name": "Named",
      "of": {
        "cases": ["normal", "success", "error"],
        "name": "Enum"
      }
    }
  ]
}
```

This will generate _roughly_ the following Swift file, `ButtonType.swift`:

```swift
enum ButtonType: String, Codable {
  case normal
  case success
  case error
}
```

### Component-local enums

Enums can be defined within a component file using Lona Studio. Enums defined within a component generate a type definition scoped to the component. In Swift, this might look like:

```swift
class Button {
  enum ButtonType: String, Codable {
    case normal
    case success
    case error
  }
}
```

The consumer of the library would then use `Button.ButtonType.normal` to access it (or more idiomatically, just `.normal`).

You can also consider removing the word "Button" from the type name, since it's redundant with the component name. Although since `Type` is already defined on Swift classes, you'll need to call it something else. E.g. you could go with `Variant`:

```swift
class Button {
  enum Variant: String, Codable {
    case normal
    case success
    case error
  }
}
```

The generated JavaScript would also live in the same file as the component, `Button.js`, and look like this:

```javascript
export const VARIANT = {
  normal: "NORMAL",
  success: "SUCCESS",
  error: "ERROR"
};
```

#### Defining Enums in Lona Studio

> The Lona Studio UI needs _a lot_ of work, but it gets the job done.

1. To define an Enum in a component, create a new component parameter in Lona Studio and set its type to "Variant":

   ![New variant type](https://i.imgur.com/89sspIT.png)

   The type name will immediately be renamed to "NewType" -- you can type in the text field next to the dropdown to choose the type name you want (e.g. ButtonType, Variant, whatever).

2. Next, define the different _cases_:

   ![Variant cases](https://i.imgur.com/nAG4hXZ.png)

   It's important to set the `type` to "Unit". This tells the compiler not to generate an algebraic data type, which is only partially supported at the moment.

3. Now you can use the Enum parameter on the _left hand side_ of an **If** statement to do something different depending on its case:

   ![Variants in logic](https://i.imgur.com/Hiepd6k.png)
