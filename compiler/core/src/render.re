let indentLine = (amount, line) => Js.String.repeat(amount, " ") ++ line;

let rec flatMap = (f, list) =>
  switch list {
  | [head, ...tail] =>
    switch head {
    | Some(a) => [a, ...flatMap(f, tail)]
    | None => []
    }
  | [] => []
  };

module String = {
  let join = (sep, items) => items |> Array.of_list |> Js.Array.joinWith(sep);
};

let prefixAll = (sep, items) => Prettier.Doc.Builders.(
  items |> List.map((x) => sep <+> x) |> concat
);

let renderOptional = (render, item) =>
  switch item {
  | None => Prettier.Doc.Builders.empty
  | Some(a) => render(a)
  };

module Swift = {
  open Prettier.Doc.Builders;
  open Ast.Swift;
  let renderFloat = (value) => {
    let string = string_of_float(value);
    let cleaned = (string |> Js.String.endsWith(".")) ? string |> Js.String.slice(~from=0, ~to_=-1) : string;
    s(cleaned)
  };
  let renderAccessLevelModifier = (node) =>
    switch node {
    | PrivateModifier => s("private")
    | FileprivateModifier => s("fileprivate")
    | InternalModifier => s("internal")
    | PublicModifier => s("public")
    | OpenModifier => s("open")
    };
  let renderMutationModifier = (node) =>
    switch node {
    | MutatingModifier => s("mutating")
    | NonmutatingModifier => s("nonmutating")
    };
  let renderDeclarationModifier = (node) =>
    switch node {
    | ClassModifier => s("class")
    | ConvenienceModifier => s("convenience")
    | DynamicModifier => s("dynamic")
    | FinalModifier => s("final")
    | InfixModifier => s("infix")
    | LazyModifier => s("lazy")
    | OptionalModifier => s("optional")
    | OverrideModifier => s("override")
    | PostfixModifier => s("postfix")
    | PrefixModifier => s("prefix")
    | RequiredModifier => s("required")
    | StaticModifier => s("static")
    | UnownedModifier => s("unowned")
    | UnownedSafeModifier => s("unownedsafe")
    | UnownedUnsafeModifier => s("unownedunsafe")
    | WeakModifier => s("weak")
    | AccessLevelModifier(v) => renderAccessLevelModifier(v)
    | MutationModifier(v) => renderMutationModifier(v)
    };
  let rec render = (ast) : Prettier.Doc.t('a) =>
    switch ast {
    | Ast.Swift.SwiftIdentifier(v) => s(v)
    | LiteralExpression(v) => renderLiteral(v)
    | MemberExpression(v) =>
      v |> List.map(render) |> join(concat([softline, s(".")])) |> group
    | BinaryExpression(o) =>
      group(render(o##left) <+> s(" ") <+> s(o##operator) <+> line <+> render(o##right))
    | ClassDeclaration(o) =>
      let maybeFinal = o##isFinal ? s("final") <+> line : empty;
      let maybeModifier = o##modifier != None ? concat([o##modifier |> renderOptional(renderAccessLevelModifier), line]) : empty;
      let maybeInherits = switch o##inherits {
        | [] => empty
        | typeAnnotations => s(": ") <+> (typeAnnotations |> List.map(renderTypeAnnotation) |> join(s(", ")));
      };
      let opening = group(concat([maybeModifier, maybeFinal, s("class"), line, s(o##name), maybeInherits, line, s("{")]));
      let closing = concat([hardline, s("}")]);
      concat([opening, o##body |> List.map(render) |> prefixAll(hardline) |> indent, closing])
    | ConstantDeclaration(o) =>
      let modifiers = o##modifiers |> List.map(renderDeclarationModifier) |> join(s(" "));
      let maybeInit =
        o##init == None ? s("") : concat([s(" = "), o##init |> renderOptional(render)]);
      let parts = [modifiers, s(" "), s("let"), s(" "), renderPattern(o##pattern), maybeInit];
      group(concat(parts))
    | VariableDeclaration(o) =>
      let modifiers = o##modifiers |> List.map(renderDeclarationModifier) |> join(s(" "));
      let maybeInit =
        o##init == None ? empty : concat([s(" = "), o##init |> renderOptional(render)]);
      let maybeBlock = o##block |> renderOptional((block) => line <+> renderInitializerBlock(block));
      let parts = [
        modifiers,
        List.length(o##modifiers) > 0 ? s(" ") : empty,
        s("var"),
        s(" "),
        renderPattern(o##pattern),
        maybeInit,
        maybeBlock
      ];
      group(concat(parts))
    | Parameter(o) =>
        (o##externalName |> renderOptional((name) => s(name) <+> s(" "))) <+>
        s(o##localName) <+>
        s(": ") <+>
        renderTypeAnnotation(o##annotation) <+>
        (o##defaultValue |> renderOptional((node) => s(" = ") <+> render(node)))
    | InitializerDeclaration(o) =>
      let parts = [
        o##modifiers |> List.map(renderDeclarationModifier) |> join(s(" ")),
        List.length(o##modifiers) > 0 ? s(" ") : empty,
        s("init"),
        o##failable |> renderOptional(s),
        s("("),
        indent(
          softline <+> join(s(",") <+> line, o##parameters |> List.map(render))
        ),
        s(")"),
        line,
        render(Ast.Swift.CodeBlock({ "statements": o##body }))
      ];
      group(concat(parts))
    | ImportDeclaration(v) => group(concat([s("import"), line, s(v)]))
    | FunctionCallArgument(o) =>
      switch o##name {
      | None => group(concat([render(o##value)]))
      | Some(name) => group(concat([render(name), s(":"), line, render(o##value)]))
      }
    | FunctionCallExpression(o) =>
      group(
        concat([
          render(o##name),
          s("("),
          concat([softline, o##arguments |> List.map(render) |> join(concat([s(","), line]))]) |> indent,
          s(")")
        ])
      )
    | LineBreak => empty /* This only works if lines are added between statements... */
    | LineComment(v) => hardline <+> s("// " ++ v)
    | LineEndComment(o) =>
      /* concat([render(o##line), lineSuffix(s(" // " ++ o##comment)), lineSuffixBoundary]) */
      concat([render(o##line), lineSuffix(s(" // " ++ o##comment))])
    | CodeBlock(o) =>
      switch o##statements {
      | [] => s("{}")
      | statements => s("{") <+> indent(line <+> join(concat([hardline]), statements |> List.map(render))) <+> line <+> s("}")
      };
    | TopLevelDeclaration(o) =>
      join(concat([hardline, hardline]), o##statements |> List.map(render))
    }
  and renderLiteral = (node: literal) =>
    switch node {
    | Nil => s("nil")
    | Boolean(value) => s(value ? "true" : "false")
    | Integer(value) => s(string_of_int(value))
    | FloatingPoint(value) => renderFloat(value)
    | String(value) => concat([s("\""), s(value), s("\"")])
    | Color(value) =>
      let rgba = Css.parseColorDefault("black", value);
      let values = [
        concat([s("red: "), renderFloat(rgba.r /. 255.0)]),
        concat([s("green: "), renderFloat(rgba.g /. 255.0)]),
        concat([s("blue: "), renderFloat(rgba.b /. 255.0)]),
        concat([s("alpha: "), renderFloat(rgba.a)]),
      ];
      concat([s("#colorLiteral("), join(s(", "), values), s(")")])
    }
  and renderTypeAnnotation = (node: typeAnnotation) =>
    switch node {
    | TypeName(value) => s(value)
    | TypeIdentifier(o) =>
      group(
        concat([
          renderTypeAnnotation(o##name),
          line,
          s("."),
          line,
          renderTypeAnnotation(o##member)
        ])
      )
    | ArrayType(o) => group(concat([s("["), renderTypeAnnotation(o##element), s("]")]))
    | DictionaryType(o) =>
      group(
        concat([
          s("["),
          renderTypeAnnotation(o##key),
          s(": "),
          renderTypeAnnotation(o##value),
          s("]")
        ])
      )
    | OptionalType(o) => group(concat([renderTypeAnnotation(o##value), s("?")]))
    | TypeInheritanceList(o) => group(o##list |> List.map(renderTypeAnnotation) |> join(s(", ")))
    }
  and renderPattern = (node) =>
    switch node {
    | WildcardPattern => s("_")
    | IdentifierPattern(o) =>
      switch o##annotation {
      | None => s(o##identifier)
      | Some(typeAnnotation) => s(o##identifier) <+> s(": ") <+> renderTypeAnnotation(typeAnnotation)
      };
    | ValueBindingPattern(o) => group(concat([s(o##kind), line, renderPattern(o##pattern)]))
    | TuplePattern(o) =>
      group(concat([s("("), o##elements |> List.map(renderPattern) |> join(s(", ")), s(")")]))
    | OptionalPattern(o) => concat([renderPattern(o##value), s("?")])
    | ExpressionPattern(o) => render(o##value)
    }
  and renderInitializerBlock = (node: initializerBlock) =>
    switch node {
    | WillSetDidSetBlock(o) =>
      let willSet = o##willSet |> renderOptional((statements) =>
        s("willSet ") <+> render(Ast.Swift.CodeBlock({ "statements": statements }))
      );
      let didSet = o##didSet |> renderOptional((statements) =>
        s("didSet ") <+> render(Ast.Swift.CodeBlock({ "statements": statements }))
      );
      switch (o##willSet, o##didSet) {
      | (None, None) => empty
      | (None, Some(_)) => group(join(line, [s("{"), didSet, s("}")]))
      | (Some(_), None) => group(join(line, [s("{"), willSet, s("}")]))
      | (Some(_), Some(_)) => s("{") <+> indent(hardline <+> willSet <+> hardline <+> didSet) <+> hardline <+> s("}")
      }
    };

  let toString = (ast) =>
    ast
    |> render
    |> (
      (doc) => {
        let printerOptions = {"printWidth": 100, "tabWidth": 2, "useTabs": false};
        Prettier.Doc.Printer.printDocToString(doc, printerOptions)##formatted
      }
    );
};

module JavaScript = {
  open Prettier.Doc.Builders;
  let renderBinaryOperator = (x) => {
    let op =
      switch x {
      | Ast.JavaScript.Eq => "==="
      | Neq => "!=="
      | Gt => ">"
      | Gte => ">="
      | Lt => "<"
      | Lte => "<="
      | Plus => "+"
      | Noop => ""
      };
    s(op)
  };
  /* Render AST */
  let rec render = (ast) : Prettier.Doc.t('a) =>
    switch ast {
    | Ast.JavaScript.Identifier(path) =>
      path |> List.map(s) |> join(concat([softline, s(".")])) |> group
    | Literal(Types.Value(_, json)) => s(Js.Json.stringify(json))
    | VariableDeclaration(value) => group(concat([s("let "), render(value), s(";")]))
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
        indent(prefixAll(hardline, body |> List.map(render))),
        hardline,
        s("};")
      ])
    | Method(name, parameters, body) =>
      let parameterList = parameters |> List.map(s) |> join(line);
      concat([
        group(concat([s(name), s("("), parameterList, s(")"), line, s("{")])),
        indent(join(hardline, body |> List.map(render))),
        line,
        s("}")
      ])
    | CallExpression(value, parameters) =>
      let parameterList = parameters |> List.map(render) |> join(s(", "));
      fill([render(value), s("("), parameterList, s(")")])
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
      concat([s(name), s("={"), value, s("}")])
    | JSXElement(tag, attributes, body) =>
      let openingContent = attributes |> List.map(render) |> join(line);
      let opening =
        group(concat([s("<"), s(tag), indent(concat([line, openingContent])), softline, s(">")]));
      let closing = group(concat([s("</"), s(tag), s(">")]));
      let children = indent(concat([line, join(line, body |> List.map(render))]));
      concat([opening, children, line, closing])
    | ArrayLiteral(body) =>
      let maybeLine = List.length(body) > 0 ? line : s("");
      let body = body |> List.map(render) |> join(concat([s(","), line]));
      group(concat([s("["), indent(concat([maybeLine, body])), maybeLine, s("]")]))
    | ObjectLiteral(body) =>
      let maybeLine = List.length(body) > 0 ? line : s("");
      let body = body |> List.map(render) |> join(concat([s(","), line]));
      group(concat([s("{"), indent(concat([maybeLine, body])), maybeLine, s("}")]))
    | ObjectProperty(name, value) => group(concat([render(name), s(": "), render(value)]))
    | Program(body) => body |> List.map(render) |> join(concat([hardline, hardline]))
    | Block(body) => body |> List.map(render) |> prefixAll(hardline)
    | Unknown => s("")
    };
  let toString = (ast) =>
    ast
    |> render
    |> (
      (doc) => {
        let printerOptions = {"printWidth": 80, "tabWidth": 2, "useTabs": false};
        Prettier.Doc.Printer.printDocToString(doc, printerOptions)##formatted
      }
    );
};