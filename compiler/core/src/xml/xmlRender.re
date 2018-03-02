open Prettier.Doc.Builders;

let quoted = doc => s("\"") <+> doc <+> s("\"");

let rec render = ast : Prettier.Doc.t('a) =>
  switch ast {
  | XmlAst.Document(o) => render(o##prolog) <+> hardline <+> render(o##element)
  | Prolog(o) =>
    switch o##xmlDecl {
    | Some(node) => render(node)
    | None => empty
    }
  | XMLDecl(o) =>
    s("<?xml ")
    <+> s("version=")
    <+> quoted(s(o##version))
    <+> (
      switch o##encoding {
      | Some(encoding) => s(" ") <+> s("encoding=") <+> quoted(s(encoding))
      | None => empty
      }
    )
    <+> s("?>")
  | Element(o) =>
    let attributes =
      switch o##attributes {
      | [] => empty
      | attributes =>
        indent(line <+> group(join(line, List.map(render, attributes))))
      };
    switch o##content {
    | [] => group(s("<") <+> s(o##tag) <+> attributes <+> s(" />"))
    | children =>
      group(
        s("<")
        <+> s(o##tag)
        <+> attributes
        <+> s(">")
        <+> group(
              indent(softline <+> join(softline, List.map(render, children)))
            )
        <+> softline
        <+> s("</")
        <+> s(o##tag)
        <+> s(">")
      )
    };
  | Comment(value) => s("<!-- " ++ value ++ " -->")
  | Attribute(o) =>
    group(s(o##name) <+> s("=") <+> indent(softline <+> quoted(s(o##value))))
  | CharData(value) => s(value)
  | Empty => empty
  };

let toString = ast =>
  ast
  |> render
  |> (
    doc => {
      let printerOptions = {
        "printWidth": 120,
        "tabWidth": 2,
        "useTabs": false
      };
      Prettier.Doc.Printer.printDocToString(doc, printerOptions)##formatted;
    }
  );