open XmlAst;

let rec join = sep =>
  fun
  | [] as items
  | [_] as items => items
  | [hd, ...tl] => [hd, sep] @ join(sep, tl);

let render = colors => {
  let colorDoc = (color: Color.t) =>
    (
      switch color.comment {
      | Some(comment) => [Comment(comment)]
      | None => []
      }
    )
    @ [
      Element({
        "tag": "color",
        "attributes": [Attribute({"name": "name", "value": color.id})],
        "content": [CharData(color.value)]
      })
    ];
  let doc =
    Document({
      "prolog":
        Prolog({
          "xmlDecl":
            Some(XMLDecl({"version": "1.0", "encoding": Some("utf-8")}))
        }),
      "element":
        Element({
          "tag": "resources",
          "attributes": [],
          "content":
            colors |> List.map(colorDoc) |> join([Empty]) |> List.concat
        })
    });
  XmlRender.toString(doc);
};
