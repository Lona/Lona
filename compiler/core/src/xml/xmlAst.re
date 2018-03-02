[@bs.deriving accessors]
type node =
  | Document(
      {
        .
        "prolog": node,
        "element": node
      }
    )
  | Prolog({. "xmlDecl": option(node)})
  | XMLDecl(
      {
        .
        "version": string,
        "encoding": option(string)
      }
    )
  | Element(
      {
        .
        "tag": string,
        "attributes": list(node),
        "content": list(node)
      }
    )
  | Comment(string)
  | Attribute(
      {
        .
        "name": string,
        "value": string
      }
    )
  | CharData(string)
  | Empty;