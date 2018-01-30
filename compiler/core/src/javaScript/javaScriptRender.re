module Ast = JavaScriptAst;

open Prettier.Doc.Builders;

let renderBinaryOperator = x => {
  let op =
    switch x {
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
  switch ast {
  | Ast.Identifier(path) =>
    path |> List.map(s) |> join(concat([softline, s(".")])) |> group
  | Literal(value) => s(Js.Json.stringify(value.data))
  | VariableDeclaration(value) =>
    group(concat([s("let "), render(value), s(";")]))
  | AssignmentExpression(name, value) =>
    fill([group(concat([render(name), line, s("=")])), s(" "), render(value)])
  | BooleanExpression(lhs, cmp, rhs) =>
    concat([render(lhs), renderBinaryOperator(cmp), render(rhs)])
  | ConditionalStatement(condition, body) =>
    concat([
      group(
        concat([
          s("if"),
          line,
          s("("),
          softline,
          render(condition),
          softline,
          s(")"),
          line,
          s("{")
        ])
      ),
      indent(join(hardline, body |> List.map(render))),
      hardline,
      s("}")
    ])
  | Class(name, extends, body) =>
    let decl =
      switch extends {
      | Some(a) => [s("class"), s(name), s("extends"), s(a)]
      | None => [s("class"), s(name)]
      };
    concat([
      group(concat([join(line, decl), s(" {")])),
      indent(Render.prefixAll(hardline, body |> List.map(render))),
      hardline,
      s("};")
    ]);
  | Method(name, parameters, body) =>
    let parameterList = parameters |> List.map(s) |> join(line);
    concat([
      group(concat([s(name), s("("), parameterList, s(")"), line, s("{")])),
      indent(join(hardline, body |> List.map(render))),
      line,
      s("}")
    ]);
  | CallExpression(value, parameters) =>
    let parameterList = parameters |> List.map(render) |> join(s(", "));
    fill([render(value), s("("), parameterList, s(")")]);
  | Return(value) =>
    group(
      concat([
        group(concat([s("return"), line, s("(")])),
        indent(concat([line, render(value)])),
        line,
        s(");")
      ])
    )
  | JSXAttribute(name, value) =>
    let value = render(value);
    concat([s(name), s("={"), value, s("}")]);
  | JSXElement(tag, attributes, body) =>
    let openingContent = attributes |> List.map(render) |> join(line);
    let opening =
      group(
        concat([
          s("<"),
          s(tag),
          indent(concat([line, openingContent])),
          softline,
          s(">")
        ])
      );
    let closing = group(concat([s("</"), s(tag), s(">")]));
    let children =
      indent(concat([line, join(line, body |> List.map(render))]));
    concat([opening, children, line, closing]);
  | ArrayLiteral(body) =>
    let maybeLine = List.length(body) > 0 ? line : s("");
    let body = body |> List.map(render) |> join(concat([s(","), line]));
    group(
      concat([s("["), indent(concat([maybeLine, body])), maybeLine, s("]")])
    );
  | ObjectLiteral(body) =>
    let maybeLine = List.length(body) > 0 ? line : s("");
    let body = body |> List.map(render) |> join(concat([s(","), line]));
    group(
      concat([s("{"), indent(concat([maybeLine, body])), maybeLine, s("}")])
    );
  | ObjectProperty(name, value) =>
    group(concat([render(name), s(": "), render(value)]))
  | Program(body) =>
    body |> List.map(render) |> join(concat([hardline, hardline]))
  | Block(body) => body |> List.map(render) |> Render.prefixAll(hardline)
  | Unknown => s("")
  };

let toString = ast =>
  ast
  |> render
  |> (
    doc => {
      let printerOptions = {"printWidth": 80, "tabWidth": 2, "useTabs": false};
      Prettier.Doc.Printer.printDocToString(doc, printerOptions)##formatted;
    }
  );
