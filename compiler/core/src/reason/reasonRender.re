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
      ~joinDelimiter: doc('a),
      ~contents: list(doc('a)),
    )
    : doc('a) =>
  if (contents == []) {
    s(startDelimiter ++ endDelimiter);
  } else {
    s(startDelimiter)
    <+> group(
          indent(line <+> (contents |> join(joinDelimiter <+> line)))
          <+> line,
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
      ~joinDelimiter=s(","),
      ~contents=nodes |> List.map(renderExpression),
    )
  | Record(entries) =>
    renderDelimitedBlock(
      ~startDelimiter="{",
      ~endDelimiter="}",
      ~joinDelimiter=s(","),
      ~contents=entries |> List.map(renderRecordEntry),
    )
  }
and renderIdentifier = (node: string): doc('a) =>
  if (reservedWords |> List.mem(node)) {
    s(node ++ "_");
  } else {
    s(node);
  }
and renderFunctionParameter = (node: functionParameter): doc('a) =>
  switch (node.annotation) {
  | Some(annotation) =>
    renderIdentifier(node.name)
    <+> s(": ")
    <+> renderTypeAnnotation(annotation)
  | None => renderIdentifier(node.name)
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
          ~joinDelimiter=s(","),
          ~contents=value.arguments |> List.map(renderExpression),
        )
  | FunctionExpression(value) =>
    renderDelimitedBlock(
      ~startDelimiter="(",
      ~endDelimiter=")",
      ~joinDelimiter=s(","),
      ~contents=value.parameters |> List.map(renderFunctionParameter),
    )
    <+> (
      value.returnType
      |> Monad.map(returnType =>
           s(": ") <+> renderTypeAnnotation(returnType)
         )
    )
    %? s("")
    <+> s(" => ")
    <+> renderDelimitedBlock(
          ~startDelimiter="{",
          ~endDelimiter="}",
          ~joinDelimiter=s(""),
          ~contents=value.body |> List.map(renderDeclaration),
        )
  | SwitchExpression(value) =>
    s("switch (")
    <+> renderExpression(value.pattern)
    <+> s(") {")
    <+> hardline
    <+> (value.cases |> List.map(renderSwitchCase) |> join(hardline))
    <+> hardline
    <+> s("}")
  }
and renderTypeAnnotation = (node: typeAnnotation): doc('a) =>
  switch (node) {
  | {name: "=>", parameters: [args, ret]} =>
    renderTypeAnnotation(args) <+> s(" => ") <+> renderTypeAnnotation(ret)
  | {name, parameters} when Js.String.startsWith("(", name) =>
    renderTypeAnnotationList(parameters)
  | {name, parameters} =>
    renderIdentifier(name) <+> renderTypeAnnotationList(parameters)
  }
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
and renderSwitchCase = (node: switchCase): doc('a) =>
  s("| ")
  <+> renderExpression(node.pattern)
  <+> s(" =>")
  <+> indent(
        line <+> (node.body |> List.map(renderDeclaration) |> join(hardline)),
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
  | AliasType(value) => renderTypeAnnotation(value)
  }
and renderTypeDeclaration = (node: typeDeclaration): doc('a) =>
  renderTypeAnnotation(node.name)
  <+> s(" =")
  <+> indent(line <+> renderTypeDeclarationValue(node.value))
and renderQuantifiedTypeAnnotation =
    (node: quantifiedTypeAnnotation): doc('a) => {
  let forall =
    node.forall |> List.map(renderIdentifier) |> join(s(" ")) <+> s(".");
  s(": ")
  <+> (node.forall == [] ? s("") : forall)
  <+> renderTypeAnnotation(node.annotation);
}
and renderVariableDeclaration = (node: variableDeclaration): doc('a) => {
  let name = renderIdentifier(node.name);
  let annotation =
    node.quantifiedAnnotation |> Monad.map(renderQuantifiedTypeAnnotation);
  name
  <+> annotation
  %? s("")
  <+> s(" = ")
  <+> renderExpression(node.initializer_);
}
and renderDeclaration = (node: declaration): doc('a) =>
  (
    switch (node) {
    | Type(nodes) =>
      s("type ")
      <+> (
        nodes
        |> List.map(renderTypeDeclaration)
        |> join(hardline <+> hardline <+> s("and "))
      )

    | Variable(nodes) =>
      s("let rec ")
      <+> (
        nodes
        |> List.map(renderVariableDeclaration)
        |> join(hardline <+> hardline <+> s("and "))
      )
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
    | Open(names) =>
      s("open ") <+> (names |> List.map(renderIdentifier) |> join(s(".")))
    | Expression(node) => renderExpression(node)
    }
  )
  <+> s(";");

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