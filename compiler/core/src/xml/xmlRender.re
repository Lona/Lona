open Prettier.Doc.Builders;

let quoted = doc => s("\"") <+> doc <+> s("\"");

let rec renderDocument = (document: XmlAst.document): Prettier.Doc.t('a) =>
  renderProlog(document.prolog)
  <+> hardline
  <+> renderElement(document.element)
and renderProlog = prolog =>
  switch (prolog.xmlDecl) {
  | Some(node) => renderXmlDecl(node)
  | None => empty
  }
and renderXmlDecl = xmlDecl =>
  s("<?xml ")
  <+> s("version=")
  <+> quoted(s(xmlDecl.version))
  <+> (
    switch (xmlDecl.encoding) {
    | Some(encoding) => s(" ") <+> s("encoding=") <+> quoted(s(encoding))
    | None => empty
    }
  )
  <+> s("?>")
and renderElement = element => {
  let attributes =
    switch (element.attributes) {
    | [] => empty
    | attributes =>
      indent(
        line <+> group(join(line, List.map(renderAttribute, attributes))),
      )
    };
  switch (element.content) {
  | [] => group(s("<") <+> s(element.tag) <+> attributes <+> s(" />"))
  | children =>
    group(
      s("<")
      <+> s(element.tag)
      <+> attributes
      <+> s(">")
      <+> group(
            indent(
              softline <+> join(softline, List.map(renderContent, children)),
            ),
          )
      <+> softline
      <+> s("</")
      <+> s(element.tag)
      <+> s(">"),
    )
  };
}
and renderContent = content =>
  switch (content) {
  | Empty => renderEmpty()
  | Comment(comment) => renderComment(comment)
  | CharData(charData) => renderCharData(charData)
  | Element(element) => renderElement(element)
  }
and renderAttribute = attribute =>
  group(
    s(attribute.name)
    <+> s("=")
    <+> indent(softline <+> quoted(s(attribute.value))),
  )
and renderComment = comment => s("<!-- " ++ comment ++ " -->")
/* TODO: Escape */
and renderCharData = s
and renderEmpty = () => empty;

let toString = (formatted: Prettier.Doc.t('a)): string => {
  let printerOptions = {"printWidth": 120, "tabWidth": 2, "useTabs": false};
  Prettier.Doc.Printer.printDocToString(formatted, printerOptions)##formatted;
};

type hi = [ | `A | `B];