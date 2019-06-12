open Prettier.Doc.Builders;
open ReasonAst;
open Operators;

type doc('a) = Prettier.Doc.t('a);

let reservedWords = ["initializer"];

let renderFloat = value => s(Format.floatToString(value));

let comma = ","; /* Workaround for syntax highlighting issue in default args */

let renderDelimitedBlock =
    (
      ~startDelimiter: string,
      ~endDelimiter: string,
      ~contents: list(doc('a)),
    )
    : doc('a) =>
  if (contents == []) {
    s(startDelimiter ++ endDelimiter);
  } else {
    s(startDelimiter)
    <+> group(
          indent(line <+> (contents |> join(s(",") <+> line))) <+> line,
        )
    <+> s(endDelimiter);
  };

let rec renderRecordEntry = (node: recordEntry): doc('a) =>
  renderIdentifier(node.key) <+> s(": ") <+> renderExpression(node.value)
and renderLiteral = (node: literal): doc('a) =>
  switch (node) {
  | Boolean(value) => value ? s("true") : s("false")
  | Number(value) => renderFloat(value)
  | String(value) =>
    concat([
      s("\""),
      s(value |> Js.String.replaceByRe([%re "/\"/g"], "\\\"")),
      s("\""),
    ])
  | Array(nodes) =>
    renderDelimitedBlock(
      ~startDelimiter="[",
      ~endDelimiter="]",
      ~contents=nodes |> List.map(renderExpression),
    )
  | Record(entries) =>
    renderDelimitedBlock(
      ~startDelimiter="{",
      ~endDelimiter="}",
      ~contents=entries |> List.map(renderRecordEntry),
    )
  }
and renderIdentifier = (node: string): doc('a) =>
  if (reservedWords |> List.mem(node)) {
    s(node ++ "_");
  } else {
    s(node);
  }
and renderExpression = (node: expression): doc('a) =>
  switch (node) {
  | LiteralExpression(value) => renderLiteral(value.literal)
  | IdentifierExpression(value) => renderIdentifier(value.name)
  | MemberExpression(value) =>
    renderExpression(value.expression)
    <+> s(".")
    <+> renderIdentifier(value.memberName)
  | FunctionCallExpression(value) =>
    renderExpression(value.expression)
    <+> renderDelimitedBlock(
          ~startDelimiter="(",
          ~endDelimiter=")",
          ~contents=value.arguments |> List.map(renderExpression),
        )
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
and renderVariableDeclaration = (node: variableDeclaration): doc('a) => {
  let name = renderIdentifier(node.name);
  let annotation =
    node.annotation
    |> Monad.map((annotation: typeAnnotation) =>
         s(": ") <+> renderTypeAnnotation(annotation)
       );
  name
  <+> annotation
  %? s("")
  <+> s(" = ")
  <+> renderExpression(node.initializer_);
}
and renderDeclaration = (node: declaration): doc('a) =>
  switch (node) {
  | Type(nodes) =>
    s("type ")
    <+> (
      nodes
      |> List.map(renderTypeDeclaration)
      |> join(hardline <+> hardline <+> s("and "))
    )
    <+> s(";")
  | Variable(nodes) =>
    s("let ")
    <+> (
      nodes
      |> List.map(renderVariableDeclaration)
      |> join(hardline <+> hardline <+> s("and "))
    )
    <+> s(";")
  | Module(node) =>
    s("module ")
    <+> renderIdentifier(node.name)
    <+> s(" = {")
    <+> indent(
          hardline
          <+> (
            node.declarations
            |> List.map(renderDeclaration)
            |> join(hardline <+> hardline)
          ),
        )
    <+> hardline
    <+> s("}")
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