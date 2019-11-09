open XmlAst;

let rec join = sep =>
  fun
  | [] as items
  | [_] as items => items
  | [hd, ...tl] => [hd, sep] @ join(sep, tl);

let render = colors: string => {
  let colorDoc = (color: Color.t): list(XmlAst.content) =>
    (
      switch (color.comment) {
      | Some(comment) => [Comment(comment)]
      | None => []
      }
    )
    @ [
      Element({
        tag: "color",
        attributes: [{name: "name", value: color.id}],
        content: [CharData(color.value)],
      }),
    ];
  let doc: XmlAst.document = {
    prolog: {
      xmlDecl: Some({version: "1.0", encoding: Some("utf-8")}),
    },
    element: {
      tag: "resources",
      attributes: [],
      content: colors |> List.map(colorDoc) |> join([Empty]) |> List.concat,
    },
  };

  doc |> XmlRender.renderDocument |> XmlRender.toString;
};