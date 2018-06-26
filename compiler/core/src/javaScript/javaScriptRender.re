module Ast = JavaScriptAst;

open Prettier.Doc.Builders;

let renderBinaryOperator = x => {
  let op =
    switch (x) {
    | Ast.Eq => "==="
    | Neq => "!=="
    | Gt => ">"
    | Gte => ">="
    | Lt => "<"
    | Lte => "<="
    | Plus => "+"
    | Noop => ""
    };
  s(op);
};

/* Render AST */
let rec render = ast : Prettier.Doc.t('a) =>
  switch (ast) {
  | Ast.Identifier(path) =>
    path |> List.map(s) |> join(softline <+> s(".")) |> group
  | Literal(value) => s(Js.Json.stringify(value.data))
  | StringLiteral(value) =>
    concat([
      s("\""),
      s(value |> Js.String.replaceByRe([%re "/\"/g"], "\\\"")),
      s("\""),
    ])
  | VariableDeclaration(value) => group(s("let ") <+> render(value))
  | AssignmentExpression(o) =>
    fill([
      group(render(o##left) <+> line <+> s("=")),
      s(" "),
      render(o##right),
    ])
  | BinaryExpression(o) =>
    render(o##left)
    <+> renderBinaryOperator(o##operator)
    <+> render(o##right)
  | IfStatement(o) =>
    group(
      s("if")
      <+> line
      <+> s("(")
      <+> softline
      <+> render(o##test)
      <+> softline
      <+> s(")")
      <+> line
      <+> s("{"),
    )
    <+> indent(join(hardline, o##consequent |> List.map(render)))
    <+> hardline
    <+> s("}")
  | ImportDefaultSpecifier(o) => s(o)
  | ImportSpecifier(o) =>
    switch (o##local) {
    | Some(local) => s(o##imported ++ " as " ++ local)
    | None => s(o##imported)
    }
  | ImportDeclaration(o) =>
    let defaultSpecifiers =
      o##specifiers
      |> List.filter(
           fun
           | Ast.ImportDefaultSpecifier(_) => true
           | _ => false,
         );
    let specifiers =
      o##specifiers
      |> List.filter(
           fun
           | Ast.ImportSpecifier(_) => true
           | _ => false,
         );
    let namedImports =
      group(
        s("{")
        <+> line
        <+> (specifiers |> List.map(render) |> join(s(", ")))
        <+> line
        <+> s("}"),
      );
    let imports =
      group(
        join(
          s(", "),
          (defaultSpecifiers |> List.map(render))
          @ (List.length(defaultSpecifiers) > 0 ? [] : [namedImports]),
        ),
      );
    group(
      s("import")
      <+> s(" ")
      <+> imports
      <+> s(" ")
      <+> s("from")
      <+> indent(line <+> s("\"" ++ o##source ++ "\"")),
    );
  | ClassDeclaration(o) =>
    let decl =
      switch (o##superClass) {
      | Some(a) => [s("class"), s(o##id), s("extends"), s(a)]
      | None => [s("class"), s(o##id)]
      };
    group(join(line, decl) <+> s(" {"))
    <+> indent(Render.prefixAll(hardline, o##body |> List.map(render)))
    <+> hardline
    <+> s("}");
  | MethodDefinition(o) => group(s(o##key) <+> render(o##value))
  | FunctionExpression(o) =>
    /* TODO: o##id */
    let parameterList = o##params |> List.map(s) |> join(line);
    group(s("(") <+> parameterList <+> s(")") <+> line <+> s("{"))
    <+> indent(join(hardline, o##body |> List.map(render)))
    <+> hardline
    <+> s("}");
  | CallExpression(o) =>
    let parameterList = o##arguments |> List.map(render) |> join(s(", "));
    fill([render(o##callee), s("("), parameterList, s(")")]);
  | Return(value) =>
    group(
      group(s("return") <+> line <+> s("("))
      <+> indent(line <+> render(value))
      <+> line
      <+> s(");"),
    )
  | JSXAttribute(o) =>
    s(o##name) <+> s("={") <+> render(o##value) <+> s("}")
  | JSXElement(o) =>
    let openingContent = o##attributes |> List.map(render) |> join(line);
    let opening =
      group(
        s("<")
        <+> s(o##tag)
        <+> indent(line <+> openingContent)
        <+> softline
        <+> s(">"),
      );
    let closing = group(s("</") <+> s(o##tag) <+> s(">"));
    let children =
      indent(line <+> join(line, o##content |> List.map(render)));
    opening <+> children <+> line <+> closing;
  | JSXExpressionContainer(o) =>
    group(s("{") <+> softline <+> render(o) <+> softline <+> s("}"))
  | SpreadElement(value) => s("...") <+> render(value)
  | ArrayLiteral(body) =>
    let maybeLine = List.length(body) > 0 ? line : empty;
    let body = body |> List.map(render) |> join(s(",") <+> line);
    group(s("[") <+> indent(maybeLine <+> body) <+> maybeLine <+> s("]"));
  | ObjectLiteral(body) =>
    let maybeLine = List.length(body) > 0 ? line : empty;
    let body = body |> List.map(render) |> join(s(",") <+> line);
    group(s("{") <+> indent(maybeLine <+> body) <+> maybeLine <+> s("}"));
  | Property(o) => group(render(o##key) <+> s(": ") <+> render(o##value))
  | ExportDefaultDeclaration(value) =>
    s("export default ") <+> render(value) <+> s(";")
  | Program(body) => body |> List.map(render) |> join(hardline)
  | Block(body) => body |> List.map(render) |> Render.prefixAll(hardline)
  | LineEndComment(o) =>
    concat([render(o##line), lineSuffix(s(" // " ++ o##comment))])
  | Empty
  | Unknown => empty
  };

let toString = ast =>
  ast
  |> render
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
