open Prettier.Doc.Builders;
open ReasonAst;

type doc('a) = Prettier.Doc.t('a);

let reservedWords = ["initializer"];

let renderFloat = value => s(Format.floatToString(value));

let rec renderLiteral = (node: literal): doc('a) =>
  switch (node) {
  | Boolean(value) => value ? s("true") : s("false")
  | Number(value) => renderFloat(value)
  | String(value) =>
    concat([
      s("\""),
      s(value |> Js.String.replaceByRe([%re "/\"/g"], "\\\"")),
      s("\""),
    ])
  | Array(_) => s("[TODO]")
  }
and renderIdentifier = (node: string): doc('a) =>
  if (reservedWords |> List.mem(node)) {
    s(node ++ "_");
  } else {
    s(node);
  }
and renderTypeAnnotation = (node: typeAnnotation): doc('a) =>
  renderIdentifier(node.name) <+> renderTypeAnnotationList(node.parameters)
and renderTypeAnnotationList = (nodes: list(typeAnnotation)): doc('a) =>
  if (nodes == []) {
    s("");
  } else {
    s("(")
    <+> group(
          indent(
            softline
            <+> (
              nodes
              |> List.map(renderTypeAnnotation)
              |> join(s(",") <+> line)
            ),
          )
          <+> softline,
        )
    <+> s(")");
  }
and renderVariantCase = (node: variantCase): doc('a) =>
  s("| ")
  <+> indent(
        renderIdentifier(node.name)
        <+> renderTypeAnnotationList(node.associatedData),
      )
and renderVariantType = (node: variantType): doc('a) =>
  group(node.cases |> List.map(renderVariantCase) |> join(line))
and renderRecordTypeEntry = (node: recordTypeEntry): doc('a) =>
  renderIdentifier(node.key)
  <+> s(": ")
  <+> renderTypeAnnotation(node.value)
and renderRecordType = (node: recordType): doc('a) =>
  if (node.entries == []) {
    s("{}");
  } else {
    s("{")
    <+> group(
          indent(
            line
            <+> (
              node.entries
              |> List.map(renderRecordTypeEntry)
              |> join(s(",") <+> line)
            ),
          )
          <+> line,
        )
    <+> s("}");
  }
and renderTypeDeclarationValue = (node: typeDeclarationValue): doc('a) =>
  switch (node) {
  | VariantType(value) => renderVariantType(value)
  | RecordType(value) => renderRecordType(value)
  }
and renderTypeDeclaration = (node: typeDeclaration): doc('a) =>
  renderTypeAnnotation(node.name)
  <+> s(" =")
  <+> indent(line <+> renderTypeDeclarationValue(node.value))
and renderDeclaration = (node: declaration): doc('a) =>
  switch (node) {
  | TypeDeclaration(nodes) =>
    s("type ")
    <+> (
      nodes
      |> List.map(renderTypeDeclaration)
      |> join(hardline <+> hardline <+> s("and "))
    )
    <+> s(";")
  };

let toString = (doc: doc('a)) =>
  doc
  |> (
    doc => {
      let printerOptions = {
        "printWidth": 80,
        "tabWidth": 2,
        "useTabs": false,
      };
      Prettier.Doc.Printer.printDocToString(doc, printerOptions)##formatted;
    }
  );