open Prettier.Doc.Builders;

let renderFloat = value => {
  let string = string_of_float(value);
  let cleaned =
    string |> Js.String.endsWith(".") ?
      string |> Js.String.slice(~from=0, ~to_=-1) : string;
  s(cleaned);
};

let reservedWords = ["true", "false"];

let stringWithBackticksIfNeeded = (id: string) =>
  List.mem(id, reservedWords) ? s("`") <+> s(id) <+> s("`") : s(id);

let nodeWithBackticksIfNeeded = (id: SwiftAst.node) =>
  switch (id) {
  | SwiftAst.SwiftIdentifier(string) => stringWithBackticksIfNeeded(string)
  | _ => s("$ Bad call to nodeWithBackticksIfNeeded")
  };

let renderAccessLevelModifier = node =>
  switch (node) {
  | SwiftAst.PrivateModifier => s("private")
  | FileprivateModifier => s("fileprivate")
  | InternalModifier => s("internal")
  | PublicModifier => s("public")
  | OpenModifier => s("open")
  };

let renderMutationModifier = node =>
  switch (node) {
  | SwiftAst.MutatingModifier => s("mutating")
  | NonmutatingModifier => s("nonmutating")
  };

let renderDeclarationModifier = node =>
  switch (node) {
  | SwiftAst.ClassModifier => s("class")
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

let rec render = ast: Prettier.Doc.t('a) =>
  switch (ast) {
  | SwiftAst.SwiftIdentifier(v) => s(v)
  | LiteralExpression(v) => renderLiteral(v)
  | MemberExpression(v) =>
    v
    |> List.map(render)
    |> join(concat([softline, s(".")]))
    |> indent
    |> group
  | TupleExpression(v) =>
    s("(")
    <+> (
      v
      |> List.map(render)
      |> join(concat([s(","), line]))
      |> indent
      |> group
    )
    <+> s(")")
  | BinaryExpression(o) =>
    group(
      render(o##left)
      <+> s(" ")
      <+> s(o##operator)
      <+> indent(line <+> render(o##right)),
    )
  | PrefixExpression(o) =>
    switch (o##expression) {
    | LiteralExpression(_)
    | SwiftIdentifier(_)
    | MemberExpression(_) => s(o##operator) <+> render(o##expression)
    | _ =>
      group(
        s(o##operator)
        <+> s("(")
        <+> softline
        <+> render(o##expression)
        <+> softline
        <+> s(")"),
      )
    }
  | TryExpression(o) =>
    let operator =
      switch (o##forced, o##optional) {
      | (true, false) => "try!"
      | (false, true) => "try?"
      | _ => "try"
      };
    s(operator) <+> line <+> (o##expression |> render);
  | ClassDeclaration(o) =>
    let maybeFinal = o##isFinal ? s("final") <+> line : empty;
    let maybeModifier =
      o##modifier != None ?
        concat([
          o##modifier |> Render.renderOptional(renderAccessLevelModifier),
          line,
        ]) :
        empty;
    let maybeInherits =
      switch (o##inherits) {
      | [] => empty
      | typeAnnotations =>
        s(": ")
        <+> (
          typeAnnotations |> List.map(renderTypeAnnotation) |> join(s(", "))
        )
      };
    let opening =
      group(
        concat([
          maybeModifier,
          maybeFinal,
          s("class"),
          line,
          s(o##name),
          maybeInherits,
          line,
          s("{"),
        ]),
      );
    let closing = concat([hardline, s("}")]);
    concat([
      opening,
      o##body |> List.map(render) |> Render.prefixAll(hardline) |> indent,
      closing,
    ]);
  /* Copied from ClassDeclaration */
  | StructDeclaration(o) =>
    let maybeModifier =
      o##modifier != None ?
        concat([
          o##modifier |> Render.renderOptional(renderAccessLevelModifier),
          line,
        ]) :
        empty;
    let maybeInherits =
      switch (o##inherits) {
      | [] => empty
      | typeAnnotations =>
        s(": ")
        <+> (
          typeAnnotations |> List.map(renderTypeAnnotation) |> join(s(", "))
        )
      };
    let opening =
      group(
        concat([
          maybeModifier,
          s("struct"),
          line,
          s(o##name),
          maybeInherits,
          line,
          s("{"),
        ]),
      );
    let closing = concat([hardline, s("}")]);
    concat([
      opening,
      o##body |> List.map(render) |> Render.prefixAll(hardline) |> indent,
      closing,
    ]);
  | ExtensionDeclaration(o) =>
    /* TODO: Where */
    let maybeModifier =
      o##modifier != None ?
        concat([
          o##modifier |> Render.renderOptional(renderAccessLevelModifier),
          line,
        ]) :
        empty;
    let maybeProtocols =
      switch (o##protocols) {
      | [] => empty
      | typeAnnotations =>
        s(": ")
        <+> (
          typeAnnotations |> List.map(renderTypeAnnotation) |> join(s(", "))
        )
      };
    let opening =
      group(
        concat([
          maybeModifier,
          s("extension"),
          line,
          s(o##name),
          maybeProtocols,
          line,
          s("{"),
        ]),
      );
    let closing = concat([hardline, s("}")]);
    concat([
      opening,
      o##body |> List.map(render) |> Render.prefixAll(hardline) |> indent,
      closing,
    ]);
  | EnumDeclaration(o) =>
    let maybeIndirect =
      o##isIndirect ? concat([s("indirect"), line]) : empty;
    let maybeModifier =
      o##modifier != None ?
        concat([
          o##modifier |> Render.renderOptional(renderAccessLevelModifier),
          line,
        ]) :
        empty;
    let maybeInherits =
      switch (o##inherits) {
      | [] => empty
      | typeAnnotations =>
        s(": ")
        <+> (
          typeAnnotations |> List.map(renderTypeAnnotation) |> join(s(", "))
        )
      };
    let opening =
      group(
        concat([
          maybeModifier,
          maybeIndirect,
          s("enum"),
          line,
          s(o##name),
          maybeInherits,
          line,
          s("{"),
        ]),
      );
    let closing = concat([hardline, s("}")]);
    concat([
      opening,
      o##body |> List.map(render) |> Render.prefixAll(hardline) |> indent,
      closing,
    ]);
  | TypealiasDeclaration(o) =>
    let maybeModifier =
      o##modifier != None ?
        concat([
          o##modifier |> Render.renderOptional(renderAccessLevelModifier),
          line,
        ]) :
        empty;
    group(
      maybeModifier
      <+> s("typealias")
      <+> line
      <+> s(o##name)
      <+> line
      <+> s("=")
      <+> line
      <+> renderTypeAnnotation(o##annotation),
    );
  | ConstantDeclaration(o) =>
    let modifiers =
      o##modifiers |> List.map(renderDeclarationModifier) |> join(s(" "));
    let maybeInit =
      o##init == None ?
        empty : concat([s(" = "), o##init |> Render.renderOptional(render)]);
    let parts = [
      modifiers,
      List.length(o##modifiers) > 0 ? s(" ") : empty,
      s("let "),
      renderPattern(o##pattern),
      maybeInit,
    ];
    group(concat(parts));
  | VariableDeclaration(o) =>
    let modifiers =
      o##modifiers |> List.map(renderDeclarationModifier) |> join(s(" "));
    let maybeInit =
      o##init == None ?
        empty : concat([s(" = "), o##init |> Render.renderOptional(render)]);
    let maybeBlock =
      o##block
      |> Render.renderOptional(block =>
           line <+> renderInitializerBlock(block)
         );
    let parts = [
      modifiers,
      List.length(o##modifiers) > 0 ? s(" ") : empty,
      s("var "),
      renderPattern(o##pattern),
      maybeInit,
      maybeBlock,
    ];
    group(concat(parts));
  | Parameter(o) =>
    o##externalName
    |> Render.renderOptional(name => s(name) <+> s(" "))
    <+> s(o##localName)
    <+> s(": ")
    <+> renderTypeAnnotation(o##annotation)
    <+> (
      o##defaultValue
      |> Render.renderOptional(node => s(" = ") <+> render(node))
    )
  | InitializerDeclaration(o) =>
    let parts = [
      o##modifiers |> List.map(renderDeclarationModifier) |> join(s(" ")),
      List.length(o##modifiers) > 0 ? s(" ") : empty,
      s("init"),
      o##failable |> Render.renderOptional(s),
      s("("),
      indent(
        softline
        <+> join(s(",") <+> line, o##parameters |> List.map(render)),
      ),
      s(")"),
      o##throws ? s(" throws") : empty,
      line,
      render(CodeBlock({"statements": o##body})),
    ];
    group(concat(parts));
  | DeinitializerDeclaration(body) =>
    s("deinit ") <+> render(CodeBlock({"statements": body}))
  | FunctionDeclaration(o) =>
    let renderResult = result =>
      s(" -> ") <+> (result |> renderTypeAnnotation);
    group(
      concat([
        group(
          concat([
            o##modifiers
            |> List.map(renderDeclarationModifier)
            |> join(s(" ")),
            List.length(o##modifiers) > 0 ? s(" ") : empty,
            s("func "),
            s(o##name),
            s("("),
            indent(
              softline
              <+> join(s(",") <+> line, o##parameters |> List.map(render)),
            ),
            s(")"),
            o##result |> Render.renderOptional(renderResult),
            o##throws ? s(" throws") : empty,
          ]),
        ),
        line,
        render(CodeBlock({"statements": o##body})),
      ]),
    );
  | ImportDeclaration(v) => group(concat([s("import"), line, s(v)]))
  | IfStatement(o) =>
    group(
      /* Line break here due to personal preference */
      /* hardline <+>  */
      s("if")
      <+> line
      <+> render(o##condition)
      <+> line
      <+> render(CodeBlock({"statements": o##block})),
    )
  | WhileStatement(o) =>
    group(
      s("while")
      <+> line
      <+> render(o##condition)
      <+> line
      <+> render(CodeBlock({"statements": o##block})),
    )
  | SwitchStatement(o) =>
    group(
      s("switch")
      <+> line
      <+> render(o##expression)
      <+> line
      <+> render(CodeBlock({"statements": o##cases})),
    )
  | CaseLabel(o) =>
    /* Automatically add break statement if needed, for convenience */
    let statements =
      switch (o##statements) {
      | [_, ..._] => o##statements
      | [] => [SwiftIdentifier("break")]
      };

    s("case ")
    <+> (
      o##patterns
      |> List.map(renderPattern)
      |> join(concat([s(","), line]))
    )
    <+> s(":")
    <+> indent(Render.prefixAll(hardline, statements |> List.map(render)));
  | DefaultCaseLabel(o) =>
    let statements =
      switch (o##statements) {
      | [_, ..._] => o##statements
      | [] => [SwiftIdentifier("break")]
      };

    s("default:")
    <+> indent(Render.prefixAll(hardline, statements |> List.map(render)));
  | ReturnStatement(value) =>
    group(s("return ") <+> (value |> Render.renderOptional(render)))
  | FunctionCallArgument(o) =>
    switch (o##name) {
    | None => group(concat([render(o##value)]))
    | Some(name) =>
      group(concat([render(name), s(":"), line, render(o##value)]))
    }
  | FunctionCallExpression(o) =>
    let endsWithLiteral =
      switch (o##arguments) {
      | [FunctionCallArgument(args)] =>
        switch (args##value) {
        | LiteralExpression(_) => false
        | _ => true
        }
      | _ => true
      };
    let arguments =
      concat([
        endsWithLiteral ? softline : empty,
        o##arguments |> List.map(render) |> join(concat([s(","), line])),
      ]);
    group(
      concat([
        render(o##name),
        s("("),
        endsWithLiteral ? indent(arguments) : arguments,
        s(")"),
      ]),
    );
  | EnumCase(o) =>
    let name = nodeWithBackticksIfNeeded(o##name);
    switch (o##value) {
    | None =>
      let parameters =
        switch (o##parameters) {
        | Some(annotation) => annotation |> renderTypeAnnotation
        | None => s("")
        };
      group(s("case ") <+> name <+> parameters);
    | Some(value) =>
      group(s("case ") <+> name <+> s(" = ") <+> render(value))
    };
  | CaseCondition(o) =>
    group(
      s("case ")
      <+> renderPattern(o##pattern)
      <+> line
      <+> s("=")
      <+> line
      <+> render(o##init),
    )
  | OptionalBindingCondition(o) =>
    let keyword = s(o##const ? "let" : "var");
    group(
      keyword
      <+> s(" ")
      <+> renderPattern(o##pattern)
      <+> line
      <+> render(o##init),
    );
  | Empty => empty /* This only works if lines are added between statements... */
  | LineComment(v) => s("// " ++ v)
  | DocComment(v) =>
    let comment = v |> Js.String.match([%re "/.{1,100}/g"]);
    switch (comment) {
    | None => s("///")
    | Some(chunks) =>
      s(
        chunks
        |> Js.Array.map(chunk => "/// " ++ chunk)
        |> Js.Array.joinWith("\n"),
      )
    };
  | LineEndComment(o) =>
    /* concat([render(o##line), lineSuffix(s(" // " ++ o##comment)), lineSuffixBoundary]) */
    concat([render(o##line), lineSuffix(s(" // " ++ o##comment))])
  | CodeBlock(o) =>
    switch (o##statements) {
    | [] => s("{}")
    /* | [statement] => s("{") <+> line <+> render(statement) <+> line <+> s("}") */
    | statements =>
      s("{")
      <+> indent(
            Render.prefixAll(hardline, statements |> List.map(render)),
          )
      <+> hardline
      <+> s("}")
    }
  | StatementListHelper(v) =>
    /* TODO: Get rid of this? */
    join(hardline, v |> List.map(render))
  | TopLevelDeclaration(o) =>
    /* join(concat([hardline, hardline]), o##statements |> List.map(render)) */
    join(concat([hardline]), o##statements |> List.map(render)) <+> hardline
  }
and renderLiteral = (node: SwiftAst.literal) =>
  switch (node) {
  | Nil => s("nil")
  | Boolean(value) => s(value ? "true" : "false")
  | Integer(value) => s(string_of_int(value))
  | FloatingPoint(value) => renderFloat(value)
  | String(value) =>
    concat([
      s("\""),
      s(value |> Js.String.replaceByRe([%re "/\"/g"], "\\\"")),
      s("\""),
    ])
  | Color(value) =>
    let rgba = Css.parseColorDefault("black", value);
    let values = [
      concat([s("red: "), renderFloat(rgba.r /. 255.0)]),
      concat([s("green: "), renderFloat(rgba.g /. 255.0)]),
      concat([s("blue: "), renderFloat(rgba.b /. 255.0)]),
      concat([s("alpha: "), renderFloat(rgba.a)]),
    ];
    fixedWidth(
      concat([s("#colorLiteral("), join(s(", "), values), s(")")]),
      2,
    );
  | Image(name) =>
    /* #imageLiteral(resourceName: "name") */
    fixedWidth(
      concat([s("#imageLiteral(resourceName: \""), s(name), s("\")")]),
      2,
    )
  | Array(body) =>
    let maybeLine = List.length(body) > 0 ? softline : s("");
    let body = body |> List.map(render) |> join(concat([s(","), line]));
    group(
      concat([
        s("["),
        indent(concat([maybeLine, body])),
        maybeLine,
        s("]"),
      ]),
    );
  }
and renderTypeAnnotation = (node: SwiftAst.typeAnnotation) =>
  switch (node) {
  | TypeName(value) => s(value)
  | TypeIdentifier(o) =>
    group(
      concat([
        renderTypeAnnotation(o##name),
        line,
        s("."),
        line,
        renderTypeAnnotation(o##member),
      ]),
    )
  | ArrayType(value) =>
    group(concat([s("["), renderTypeAnnotation(value), s("]")]))
  | DictionaryType(o) =>
    group(
      concat([
        s("["),
        renderTypeAnnotation(o##key),
        s(": "),
        renderTypeAnnotation(o##value),
        s("]"),
      ]),
    )
  | OptionalType(v) => group(concat([renderTypeAnnotation(v), s("?")]))
  | TupleType(o) =>
    s("(")
    <+> group(o |> List.map(renderTypeAnnotation) |> join(s(", ")))
    <+> s(")")
  | TypeInheritanceList(o) =>
    group(o##list |> List.map(renderTypeAnnotation) |> join(s(", ")))
  }
and renderPattern = node =>
  switch (node) {
  | WildcardPattern => s("_")
  | IdentifierPattern(o) =>
    switch (o##annotation) {
    | None => render(o##identifier)
    | Some(typeAnnotation) =>
      render(o##identifier)
      <+> s(": ")
      <+> renderTypeAnnotation(typeAnnotation)
    }
  | ValueBindingPattern(o) =>
    group(concat([s(o##kind), line, renderPattern(o##pattern)]))
  | TuplePattern(v) =>
    group(
      concat([
        s("("),
        v |> List.map(renderPattern) |> join(s(", ")),
        s(")"),
      ]),
    )
  | OptionalPattern(o) => concat([renderPattern(o##value), s("?")])
  | ExpressionPattern(o) => render(o##value)
  | EnumCasePattern(o) =>
    let maybeTypeIdentifier =
      switch (o##typeIdentifier) {
      | Some(id) => s(id)
      | None => s("")
      };
    let maybePattern =
      switch (o##tuplePattern) {
      | Some(pattern) => renderPattern(pattern)
      | None => s("")
      };
    group(
      maybeTypeIdentifier <+> s(".") <+> s(o##caseName) <+> maybePattern,
    );
  }
and renderInitializerBlock = (node: SwiftAst.initializerBlock) =>
  switch (node) {
  | WillSetDidSetBlock(o) =>
    /* Special case single-statement willSet/didSet and render them in a single line
       since they are common in our generated code and are easier to read than multiline */
    let renderStatements = statements =>
      switch (statements) {
      | [only] => s("{ ") <+> render(only) <+> s(" }")
      | _ => render(CodeBlock({"statements": statements}))
      };
    let willSet =
      o##willSet
      |> Render.renderOptional(statements =>
           s("willSet ") <+> renderStatements(statements)
         );
    let didSet =
      o##didSet
      |> Render.renderOptional(statements =>
           s("didSet ") <+> renderStatements(statements)
         );
    switch (o##willSet, o##didSet) {
    | (None, None) => empty
    | (None, Some(_)) => group(join(line, [s("{"), didSet, s("}")]))
    | (Some(_), None) => group(join(line, [s("{"), willSet, s("}")]))
    /* | (None, Some(_)) => s("{") <+> indent(hardline <+> didSet) <+> hardline <+> s("}")
       | (Some(_), None) => s("{") <+> indent(hardline <+> willSet) <+> hardline <+> s("}") */
    | (Some(_), Some(_)) =>
      s("{")
      <+> indent(hardline <+> willSet <+> hardline <+> didSet)
      <+> hardline
      <+> s("}")
    };
  };

let toString = ast =>
  ast
  |> render
  |> (
    doc => {
      let printerOptions = {
        "printWidth": 120,
        "tabWidth": 2,
        "useTabs": false,
      };
      Prettier.Doc.Printer.printDocToString(doc, printerOptions)##formatted;
    }
  );