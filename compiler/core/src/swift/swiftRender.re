  open Prettier.Doc.Builders;
  open SwiftAst;
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
    | SwiftIdentifier(v) => s(v)
    | LiteralExpression(v) => renderLiteral(v)
    | MemberExpression(v) =>
      v |> List.map(render) |> join(concat([softline, s(".")])) |> indent |> group
    | BinaryExpression(o) =>
      group(render(o##left) <+> s(" ") <+> s(o##operator) <+> line <+> render(o##right))
    | PrefixExpression(o) =>
      group(s(o##operator) <+> s("(") <+> softline <+> render(o##expression) <+> softline <+> s(")"))
    | ClassDeclaration(o) =>
      let maybeFinal = o##isFinal ? s("final") <+> line : empty;
      let maybeModifier = o##modifier != None ? concat([o##modifier |> Render.renderOptional(renderAccessLevelModifier), line]) : empty;
      let maybeInherits = switch o##inherits {
        | [] => empty
        | typeAnnotations => s(": ") <+> (typeAnnotations |> List.map(renderTypeAnnotation) |> join(s(", ")));
      };
      let opening = group(concat([maybeModifier, maybeFinal, s("class"), line, s(o##name), maybeInherits, line, s("{")]));
      let closing = concat([hardline, s("}")]);
      concat([opening, o##body |> List.map(render) |> Render.prefixAll(hardline) |> indent, closing])
    | ConstantDeclaration(o) =>
      let modifiers = o##modifiers |> List.map(renderDeclarationModifier) |> join(s(" "));
      let maybeInit =
        o##init == None ? empty : concat([s(" = "), o##init |> Render.renderOptional(render)]);
      let parts = [
        modifiers,
        List.length(o##modifiers) > 0 ? s(" ") : empty,
        s("let "),
        renderPattern(o##pattern),
        maybeInit
      ];
      group(concat(parts))
    | VariableDeclaration(o) =>
      let modifiers = o##modifiers |> List.map(renderDeclarationModifier) |> join(s(" "));
      let maybeInit =
        o##init == None ? empty : concat([s(" = "), o##init |> Render.renderOptional(render)]);
      let maybeBlock = o##block |> Render.renderOptional((block) => line <+> renderInitializerBlock(block));
      let parts = [
        modifiers,
        List.length(o##modifiers) > 0 ? s(" ") : empty,
        s("var "),
        renderPattern(o##pattern),
        maybeInit,
        maybeBlock
      ];
      group(concat(parts))
    | Parameter(o) =>
        (o##externalName |> Render.renderOptional((name) => s(name) <+> s(" "))) <+>
        s(o##localName) <+>
        s(": ") <+>
        renderTypeAnnotation(o##annotation) <+>
        (o##defaultValue |> Render.renderOptional((node) => s(" = ") <+> render(node)))
    | InitializerDeclaration(o) =>
      let parts = [
        o##modifiers |> List.map(renderDeclarationModifier) |> join(s(" ")),
        List.length(o##modifiers) > 0 ? s(" ") : empty,
        s("init"),
        o##failable |> Render.renderOptional(s),
        s("("),
        indent(
          softline <+> join(s(",") <+> line, o##parameters |> List.map(render))
        ),
        s(")"),
        line,
        render(CodeBlock({ "statements": o##body }))
      ];
      group(concat(parts))
    | FunctionDeclaration(o) =>
      group(concat([
        group(concat([
          o##modifiers |> List.map(renderDeclarationModifier) |> join(s(" ")),
          List.length(o##modifiers) > 0 ? s(" ") : empty,
          s("func "),
          s(o##name),
          s("("),
          indent(
            softline <+> join(s(",") <+> line, o##parameters |> List.map(render))
          ),
          s(")"),
        ])),
        line,
        render(CodeBlock({ "statements": o##body }))
      ]));
    | ImportDeclaration(v) => group(concat([s("import"), line, s(v)]))
    | IfStatement(o) =>
      group(
        hardline <+> /* Line break here due to personal preference */
        s("if") <+>
        line <+>
        render(o##condition) <+>
        line <+>
        render(CodeBlock({ "statements": o##block }))
      )
    | FunctionCallArgument(o) =>
      switch o##name {
      | None => group(concat([render(o##value)]))
      | Some(name) => group(concat([render(name), s(":"), line, render(o##value)]))
      }
    | FunctionCallExpression(o) =>
      let endsWithLiteral = switch o##arguments {
      | [FunctionCallArgument(args)] =>
        switch (args##value) {
        | LiteralExpression(_) => false
        | _ => true
        };
      | _ => true
      };
      let arguments = concat([
        endsWithLiteral ? softline : empty,
        o##arguments |> List.map(render) |> join(concat([s(","), line]))
      ]);
      group(
        concat([
          render(o##name),
          s("("),
          (endsWithLiteral ? indent(arguments) : arguments),
          s(")")
        ])
      )
    | Empty => empty /* This only works if lines are added between statements... */
    | LineComment(v) => hardline <+> s("// " ++ v)
    | LineEndComment(o) =>
      /* concat([render(o##line), lineSuffix(s(" // " ++ o##comment)), lineSuffixBoundary]) */
      concat([render(o##line), lineSuffix(s(" // " ++ o##comment))])
    | CodeBlock(o) =>
      switch o##statements {
      | [] => s("{}")
      /* | [statement] => s("{") <+> line <+> render(statement) <+> line <+> s("}") */
      | statements =>
        s("{") <+>
        indent(Render.prefixAll(hardline, statements |> List.map(render))) <+>
        hardline <+>
        s("}")
      };
    | StatementListHelper(v) => /* TODO: Get rid of this */
      join(hardline, v |> List.map(render)) <+> lineSuffix(s(" // StatementListHelper"))
    | TopLevelDeclaration(o) =>
      /* join(concat([hardline, hardline]), o##statements |> List.map(render)) */
      join(concat([hardline]), o##statements |> List.map(render))
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
    | Array(body) =>
      let maybeLine = List.length(body) > 0 ? line : s("");
      let body = body |> List.map(render) |> join(concat([s(","), line]));
      group(concat([s("["), indent(concat([maybeLine, body])), maybeLine, s("]")]))
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
    | OptionalType(v) => group(concat([renderTypeAnnotation(v), s("?")]))
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
      /* Special case single-statement willSet/didSet and render them in a single line
         since they are common in our generated code and are easier to read than multiline */
      let renderStatements = (statements) => {
        switch (statements) {
        | [only] => s("{ ") <+> render(only) <+> s(" }")
        | _ => render(CodeBlock({ "statements": statements }))
        };
      };
      let willSet = o##willSet |> Render.renderOptional((statements) =>
        s("willSet ") <+> renderStatements(statements)
      );
      let didSet = o##didSet |> Render.renderOptional((statements) =>
        s("didSet ") <+> renderStatements(statements)
      );
      switch (o##willSet, o##didSet) {
      | (None, None) => empty
      | (None, Some(_)) => group(join(line, [s("{"), didSet, s("}")]))
      | (Some(_), None) => group(join(line, [s("{"), willSet, s("}")]))
      /* | (None, Some(_)) => s("{") <+> indent(hardline <+> didSet) <+> hardline <+> s("}")
      | (Some(_), None) => s("{") <+> indent(hardline <+> willSet) <+> hardline <+> s("}") */
      | (Some(_), Some(_)) => s("{") <+> indent(hardline <+> willSet <+> hardline <+> didSet) <+> hardline <+> s("}")
      }
    };

  let toString = (ast) =>
    ast
    |> render
    |> (
      (doc) => {
        let printerOptions = {"printWidth": 120, "tabWidth": 2, "useTabs": false};
        Prettier.Doc.Printer.printDocToString(doc, printerOptions)##formatted
      }
    );
