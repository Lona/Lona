module Format = {
  [@bs.module] external camelCase : string => string = "lodash.camelcase";
  [@bs.module] external upperFirst : string => string = "lodash.upperfirst";
  let layerName = (layerName) => camelCase(layerName) ++ "View";
};

module Ast = {
  type accessLevelModifier =
    | PrivateModifier
    | FileprivateModifier
    | InternalModifier
    | PublicModifier
    | OpenModifier;
  type mutationModifier =
    | MutatingModifier
    | NonmutatingModifier;
  type declarationModifier =
    | ClassModifier
    | ConvenienceModifier
    | DynamicModifier
    | FinalModifier
    | InfixModifier
    | LazyModifier
    | OptionalModifier
    | OverrideModifier
    | PostfixModifier
    | PrefixModifier
    | RequiredModifier
    | StaticModifier
    | UnownedModifier
    | UnownedSafeModifier
    | UnownedUnsafeModifier
    | WeakModifier
    | AccessLevelModifier(accessLevelModifier)
    | MutationModifier(mutationModifier);
  type literal =
    | Nil
    | Boolean(bool)
    | Integer(int)
    | FloatingPoint(float)
    | String(string)
    | Color(string)
    | Array(list(node))
  and typeAnnotation =
    | TypeName(string)
    | TypeIdentifier({. "name": typeAnnotation, "member": typeAnnotation})
    | ArrayType({. "element": typeAnnotation})
    | DictionaryType({. "key": typeAnnotation, "value": typeAnnotation})
    | OptionalType(typeAnnotation)
    | TypeInheritanceList({. "list": list(typeAnnotation)})
  and pattern =
    | WildcardPattern
    | IdentifierPattern({. "identifier": string, "annotation": option(typeAnnotation)})
    | ValueBindingPattern({. "kind": string, "pattern": pattern})
    | TuplePattern({. "elements": list(pattern)})
    | OptionalPattern({. "value": pattern})
    | ExpressionPattern({. "value": node})
  /* | IsPattern */
  /* | AsPattern */
  and initializerBlock =
    | WillSetDidSetBlock({. "willSet": option(list(node)), "didSet": option(list(node))})
  and node =
    /* | Operator(string) */
    | LiteralExpression(literal)
    | MemberExpression(list(node))
    | BinaryExpression({. "left": node, "operator": string, "right": node})
    | PrefixExpression({. "operator": string, "expression": node})
    | ClassDeclaration(
        {
          .
          "name": string,
          "inherits": list(typeAnnotation),
          "modifier": option(accessLevelModifier),
          "isFinal": bool,
          "body": list(node)
        }
      )
    /* | VariableDeclaration({. "pattern": pattern, "init": option(node)}) */
    | SwiftIdentifier(string)
    | ConstantDeclaration(
        {. "modifiers": list(declarationModifier), "pattern": pattern, "init": option(node)}
      )
    | VariableDeclaration(
        {
          .
          "modifiers": list(declarationModifier),
          "pattern": pattern,
          "init": option(node),
          "block": option(initializerBlock)
        }
      )
    | InitializerDeclaration(
        {
          .
          "modifiers": list(declarationModifier),
          "parameters": list(node),
          "failable": option(string),
          "body": list(node)
        }
      )
    | FunctionDeclaration(
        {
          .
          "name": string,
          "modifiers": list(declarationModifier),
          "parameters": list(node),
          "body": list(node)
        }
      )
    | ImportDeclaration(string)
    | IfStatement({. "condition": node, "block": list(node)})
    | Parameter(
        {
          .
          "externalName": option(string),
          "localName": string,
          "annotation": typeAnnotation,
          "defaultValue": option(node)
        }
      )
    | FunctionCallArgument({. "name": option(node), "value": node})
    | FunctionCallExpression({. "name": node, "arguments": list(node)})
    | Empty
    | LineComment(string)
    | LineEndComment({. "comment": string, "line": node})
    | CodeBlock({. "statements": list(node)})
    | StatementListHelper(list(node))
    | TopLevelDeclaration({. "statements": list(node)});
};

module Document = {
  open Ast;
  let join = (sep, nodes) =>
    switch nodes {
    | [] => []
    | _ => nodes |> List.fold_left((acc, node) => acc @ [sep, node], [])
    };
  let joinGroups = (sep, groups) => {
    let nonEmpty = groups |> List.filter((x) => List.length(x) > 0);
    switch nonEmpty {
    | [] => []
    | [hd, ...tl] => tl |> List.fold_left((acc, nodes) => acc @ [sep] @ nodes, hd)
    }
  };
  let lonaValue = (colors, value: Types.lonaValue) =>
    switch value.ltype {
    | Reference(typeName) =>
      switch typeName {
      | "Boolean" => LiteralExpression(Boolean(value.data |> Json.Decode.bool))
      | "Number" => LiteralExpression(FloatingPoint(value.data |> Json.Decode.float))
      | "String" => LiteralExpression(String(value.data |> Json.Decode.string))
      | _ => SwiftIdentifier("UnknownReferenceType: " ++ typeName)
      }
    | Named(alias, subtype) =>
      switch alias {
      | "Color" =>
        let rawValue = value.data |> Json.Decode.string;
        switch (Color.find(colors, rawValue)) {
        | Some(color) => MemberExpression([SwiftIdentifier("Colors"), SwiftIdentifier(color.id)])
        | None => LiteralExpression(Color(rawValue))
        }
      | _ => SwiftIdentifier("UnknownNamedTypeAlias" ++ alias)
      }
    };
};

module Render = {
  open Prettier.Doc.Builders;
  open Ast;
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
    | Ast.SwiftIdentifier(v) => s(v)
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
        render(Ast.CodeBlock({ "statements": o##body }))
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
        render(Ast.CodeBlock({ "statements": o##body }))
      ]));
    | ImportDeclaration(v) => group(concat([s("import"), line, s(v)]))
    | IfStatement(o) =>
      group(
        hardline <+> /* Line break here due to personal preference */
        s("if") <+>
        line <+>
        render(o##condition) <+>
        line <+>
        render(Ast.CodeBlock({ "statements": o##block }))
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
        | _ => render(Ast.CodeBlock({ "statements": statements }))
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
};

module SwiftLogic = {
  let rec toSwiftAST = (colors, rootLayer: Types.layer, logicRootNode) => {
    let identifierName = (node) =>
      switch node {
      | Logic.Identifier(ltype, [head, ...tail]) =>
        switch head {
        | "parameters" => Ast.SwiftIdentifier(List.hd(tail))
        | "layers" =>
          switch tail {
          | [second, ...tail] when second == rootLayer.name =>
            Ast.SwiftIdentifier(
              List.tl(tail)
              |> List.fold_left((a, b) => a ++ "." ++ Format.camelCase(b), List.hd(tail))
            )
          | [second, ...tail] =>
            Ast.SwiftIdentifier(
              tail
              |> List.fold_left(
                   (a, b) => a ++ "." ++ Format.camelCase(b),
                   Format.layerName(second)
                 )
            )
          | _ => SwiftIdentifier("BadIdentifier")
          }
        | _ => SwiftIdentifier("BadIdentifier")
        }
      | _ => SwiftIdentifier("BadIdentifier")
      };
    let logicValueToSwiftAST = (x) =>
      switch x {
      | Logic.Identifier(_) => identifierName(x)
      | Literal(value) => Document.lonaValue(colors, value)
      | None => Empty
      };
    let typeAnnotationDoc =
      fun
      | Types.Reference(typeName) =>
        switch typeName {
        | "Boolean" => Ast.TypeName("Bool")
        | _ => TypeName(typeName)
        }
      | Named(name, _) => TypeName(name);
    let fromCmp = (x) =>
      switch x {
      | Types.Eq => "=="
      | Neq => "!="
      | Gt => ">"
      | Gte => ">="
      | Lt => "<"
      | Lte => "<="
      | Unknown => "???"
      };
    let unwrapBlock =
      fun
      | Logic.Block(body) => body
      | node => [node];
    let rec inner = (logicRootNode) =>
      switch logicRootNode {
      | Logic.Assign(a, b) =>
        let (left, right) =
          switch (logicValueToSwiftAST(b), logicValueToSwiftAST(a)) {
          | (Ast.SwiftIdentifier(name), LiteralExpression(Boolean(value)))
              when name |> Js.String.endsWith("visible") => (
              Ast.SwiftIdentifier(name |> Js.String.replace("visible", "isHidden")),
              Ast.LiteralExpression(Boolean(! value))
            )
          | (Ast.SwiftIdentifier(name), right) when name |> Js.String.endsWith("borderRadius") => (
              Ast.SwiftIdentifier(
                name |> Js.String.replace("borderRadius", "layer.cornerRadius")
              ),
              right
            )
          | (Ast.SwiftIdentifier(name), right) when name |> Js.String.endsWith("height") => (
              Ast.SwiftIdentifier(
                name |> Js.String.replace(".height", "HeightAnchorConstraint?.constant")
              ),
              right
            )
          | (Ast.SwiftIdentifier(name), right) when name |> Js.String.endsWith("width") => (
              Ast.SwiftIdentifier(
                name |> Js.String.replace(".width", "WidthAnchorConstraint?.constant")
              ),
              right
            )
          | nodes => nodes
          };
        Ast.BinaryExpression({"left": left, "operator": "=", "right": right})
      | IfExists(a, body) =>
        /* TODO: Once we support optional params, compare to nil or extract via pattern */
        Ast.IfStatement({
          "condition": logicValueToSwiftAST(a),
          "block": unwrapBlock(body) |> List.map(inner)
        })
      | Block(body) => Ast.StatementListHelper(body |> List.map(inner))
      | If(a, cmp, b, body) =>
        Ast.IfStatement({
          "condition":
            Ast.BinaryExpression({
              "left": logicValueToSwiftAST(a),
              "operator": fromCmp(cmp),
              "right": logicValueToSwiftAST(b)
            }),
          "block": unwrapBlock(body) |> List.map(inner)
        })
      | Add(lhs, rhs, value) =>
        BinaryExpression({
          "left": logicValueToSwiftAST(value),
          "operator": "=",
          "right":
            Ast.BinaryExpression({
              "left": logicValueToSwiftAST(lhs),
              "operator": "+",
              "right": logicValueToSwiftAST(rhs)
            })
        })
      | Let(value) =>
        switch value {
        | Identifier(ltype, path) =>
          Ast.VariableDeclaration({
            "modifiers": [],
            "pattern":
              Ast.IdentifierPattern({
                "identifier": List.fold_left((a, b) => a ++ "." ++ b, List.hd(path), List.tl(path)),
                "annotation": Some(ltype |> typeAnnotationDoc)
              }),
            "init": (None: option(Ast.node)),
            "block": (None: option(Ast.initializerBlock))
          })
        | _ => Empty
        }
      | None => Empty
      };
    logicRootNode |> unwrapBlock |> List.map(inner)
  };
};


module Color = {
  let render = (target, colors) =>
    switch target {
    | Types.Swift =>
      open Ast;
      let colorConstantDoc = (color: Color.t) =>
        LineEndComment({
          "comment": color.value,
          "line":
            ConstantDeclaration({
              "modifiers": [AccessLevelModifier(PublicModifier), StaticModifier],
              "pattern": IdentifierPattern({"identifier": color.id, "annotation": None}),
              "init": Some(LiteralExpression(Color(color.value)))
            })
        });
      let doc =
        TopLevelDeclaration({
          "statements": [
            ImportDeclaration("UIKit"),
            Empty,
            ClassDeclaration({
              "name": "Colors",
              "inherits": [],
              "modifier": None,
              "isFinal": false,
              "body": colors |> List.map(colorConstantDoc)
            })
          ]
        });
      Render.toString(doc)
    | _ =>
      Js.log2("Color generation not supported for target", target);
      "error"
    };
};

module Component = {
  type layoutPriority =
    | Required
    | Low;
  type constraintDefinition = {
    variableName: string,
    initialValue: Ast.node,
    priority: layoutPriority
  };
  type directionParameter = {
    lonaName: string,
    swiftName: string
  };
  let generate = (name, json, colors) => {
    let rootLayer = json |> Decode.Component.rootLayer;
    /* Remove the root element */
    let nonRootLayers = rootLayer |> Layer.flatten |> List.tl;
    let logic = json |> Decode.Component.logic;
    let assignments = Layer.parameterAssignmentsFromLogic(rootLayer, logic);
    let parameters = json |> Decode.Component.parameters;
    open Ast;
    let priorityName =
      fun
      | Required => "required"
      | Low => "defaultLow";
    let typeAnnotationDoc =
      fun
      | Types.Reference(typeName) =>
        switch typeName {
        | "Boolean" => TypeName("Bool")
        | _ => TypeName(typeName)
        }
      | Named(name, _) => TypeName(name);
    let parameterVariableDoc = (parameter: Decode.parameter) =>
      VariableDeclaration({
        "modifiers": [AccessLevelModifier(PublicModifier)],
        "pattern":
          IdentifierPattern({
            "identifier": parameter.name,
            "annotation": Some(parameter.ltype |> typeAnnotationDoc)
          }),
        "init": None,
        "block":
          Some(
            WillSetDidSetBlock({
              "willSet": None,
              "didSet":
                Some([
                  FunctionCallExpression({"name": SwiftIdentifier("update"), "arguments": []})
                ])
            })
          )
      });
    /* let viewTypeDoc =
      fun
      | Types.View => TypeName("UIView")
      | Text => TypeName("UILabel")
      | Image => TypeName("UIImageView")
      | _ => TypeName("TypeUnknown"); */
    let viewTypeInitDoc =
      fun
      | Types.View => SwiftIdentifier("UIView")
      | Text => SwiftIdentifier("UILabel")
      | Image => SwiftIdentifier("UIImageView")
      | _ => SwiftIdentifier("TypeUnknown");
    let viewVariableDoc = (layer: Types.layer) =>
      VariableDeclaration({
        "modifiers": [AccessLevelModifier(PrivateModifier)],
        "pattern":
          IdentifierPattern({
            "identifier": layer.name |> Format.layerName,
            "annotation": None /*Some(layer.typeName |> viewTypeDoc)*/
          }),
        "init":
          Some(
            FunctionCallExpression({
              "name": layer.typeName |> viewTypeInitDoc,
              "arguments":
                layer.typeName == Types.Text ?
                  [] :
                  [
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("frame")),
                      "value": SwiftIdentifier(".zero")
                    })
                  ]
            })
          ),
        "block": None
      });
    let constraintVariableDoc = (variableName) =>
      VariableDeclaration({
        "modifiers": [AccessLevelModifier(PrivateModifier)],
        "pattern":
          IdentifierPattern({
            "identifier": variableName,
            "annotation": Some(OptionalType(TypeName("NSLayoutConstraint")))
          }),
        "init": None,
        "block": None
      });
    let paddingParameters = [
      {swiftName: "topPadding", lonaName: "paddingTop"},
      {swiftName: "trailingPadding", lonaName: "paddingRight"},
      {swiftName: "bottomPadding", lonaName: "paddingBottom"},
      {swiftName: "leadingPadding", lonaName: "paddingLeft"}
    ];
    let marginParameters = [
      {swiftName: "topMargin", lonaName: "marginTop"},
      {swiftName: "trailingMargin", lonaName: "marginRight"},
      {swiftName: "bottomMargin", lonaName: "marginBottom"},
      {swiftName: "leadingMargin", lonaName: "marginLeft"}
    ];
    let spacingVariableDoc = (layer: Types.layer) => {
      let variableName = (variable) =>
        layer === rootLayer ?
          variable : Format.layerName(layer.name) ++ Format.upperFirst(variable);
      let marginVariables =
        layer === rootLayer ?
          [] :
          {
            let createVariable = (marginParameter: directionParameter) =>
              VariableDeclaration({
                "modifiers": [AccessLevelModifier(PrivateModifier)],
                "pattern":
                  IdentifierPattern({
                    "identifier": variableName(marginParameter.swiftName),
                    "annotation": Some(TypeName("CGFloat"))
                  }),
                "init":
                  Some(
                    LiteralExpression(
                      FloatingPoint(Layer.getNumberParameter(marginParameter.lonaName, layer))
                    )
                  ),
                "block": None
              });
            marginParameters |> List.map(createVariable)
          };
      let paddingVariables =
        switch layer.children {
        | [] => []
        | _ =>
          let createVariable = (paddingParameter: directionParameter) =>
            VariableDeclaration({
              "modifiers": [AccessLevelModifier(PrivateModifier)],
              "pattern":
                IdentifierPattern({
                  "identifier": variableName(paddingParameter.swiftName),
                  "annotation": Some(TypeName("CGFloat"))
                }),
              "init":
                Some(
                  LiteralExpression(
                    FloatingPoint(Layer.getNumberParameter(paddingParameter.lonaName, layer))
                  )
                ),
              "block": None
            });
          paddingParameters |> List.map(createVariable)
        };
      marginVariables @ paddingVariables
    };
    let initParameterDoc = (parameter: Decode.parameter) =>
      Parameter({
        "externalName": None,
        "localName": parameter.name,
        "annotation": parameter.ltype |> typeAnnotationDoc,
        "defaultValue": None
      });
    let initParameterAssignmentDoc = (parameter: Decode.parameter) =>
      BinaryExpression({
        "left": MemberExpression([SwiftIdentifier("self"), SwiftIdentifier(parameter.name)]),
        "operator": "=",
        "right": SwiftIdentifier(parameter.name)
      });
    let initializerCoderDoc = () =>
      /* required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
         } */
      InitializerDeclaration({
        "modifiers": [AccessLevelModifier(PublicModifier), RequiredModifier],
        "parameters": [
          Parameter({
            "externalName": Some("coder"),
            "localName": "aDecoder",
            "annotation": TypeName("NSCoder"),
            "defaultValue": None
          })
        ],
        "failable": Some("?"),
        "body": [
          FunctionCallExpression({
            "name": SwiftIdentifier("fatalError"),
            "arguments": [
              FunctionCallArgument({
                "name": None,
                "value": SwiftIdentifier("\"init(coder:) has not been implemented\"")
              })
            ]
          })
        ]
      });
    let initializerDoc = () =>
      InitializerDeclaration({
        "modifiers": [AccessLevelModifier(PublicModifier)],
        "parameters": parameters |> List.map(initParameterDoc),
        "failable": None,
        "body":
          Document.joinGroups(
            Empty,
            [
              parameters |> List.map(initParameterAssignmentDoc),
              [
                MemberExpression([
                  SwiftIdentifier("super"),
                  FunctionCallExpression({
                    "name": SwiftIdentifier("init"),
                    "arguments": [
                      FunctionCallArgument({
                        "name": Some(SwiftIdentifier("frame")),
                        "value": SwiftIdentifier(".zero")
                      })
                    ]
                  })
                ])
              ],
              [
                FunctionCallExpression({"name": SwiftIdentifier("setUpViews"), "arguments": []}),
                FunctionCallExpression({
                  "name": SwiftIdentifier("setUpConstraints"),
                  "arguments": []
                })
              ],
              [FunctionCallExpression({"name": SwiftIdentifier("update"), "arguments": []})]
            ]
          )
      });
    let memberOrSelfExpression = (firstIdentifier, statements) =>
      switch firstIdentifier {
      | "self" => MemberExpression(statements)
      | _ => MemberExpression([SwiftIdentifier(firstIdentifier)] @ statements)
      };
    let parentNameOrSelf = (parent: Types.layer) =>
      parent === rootLayer ? "self" : parent.name |> Format.layerName;
    let layerMemberExpression = (layer: Types.layer, statements) =>
      memberOrSelfExpression(parentNameOrSelf(layer), statements);
    let defaultValueForParameter =
      fun
      | "backgroundColor" =>
        MemberExpression([SwiftIdentifier("UIColor"), SwiftIdentifier("clear")])
      | _ => LiteralExpression(Integer(0));
    let initialLayerValue = (layer: Types.layer, name) =>
      switch (StringMap.find_opt(name, layer.parameters)) {
      | Some(value) => Document.lonaValue(colors, value)
      | None => defaultValueForParameter(name)
      };
    let defineInitialLayerValue = (layer: Types.layer, (name, _)) => {
      let (left, right) =
        switch (name, initialLayerValue(layer, name)) {
        | ("visible", LiteralExpression(Boolean(value))) => (
            layerMemberExpression(layer, [SwiftIdentifier("isHidden")]),
            LiteralExpression(Boolean(! value))
          )
        | ("borderRadius", LiteralExpression(FloatingPoint(_)) as right) => (
            layerMemberExpression(
              layer,
              [SwiftIdentifier("layer"), SwiftIdentifier("cornerRadius")]
            ),
            right
          )
        | ("height", LiteralExpression(FloatingPoint(_)) as right) => (
            SwiftIdentifier(parentNameOrSelf(layer) ++ "HeightAnchorConstraint?.constant"),
            right
          )
        | ("width", LiteralExpression(FloatingPoint(_)) as right) => (
            SwiftIdentifier(parentNameOrSelf(layer) ++ "WidthAnchorConstraint?.constant"),
            right
          )
        | (_, right) => (layerMemberExpression(layer, [SwiftIdentifier(name)]), right)
        };
      BinaryExpression({"left": left, "operator": "=", "right": right})
    };
    let setUpViewsDoc = (root: Types.layer) => {
      let setUpDefaultsDoc = () => {
        let filterParameters = ((name, _)) =>
          name != "image"
          && name != "textStyle"
          && name != "flexDirection"
          && name != "justifyContent"
          && name != "alignSelf"
          && name != "alignItems"
          && name != "flex"
          && name != "font"
          && ! Js.String.startsWith("padding", name)
          && ! Js.String.startsWith("margin", name)
          /* Handled by initial constraint setup */
          && name != "height"
          && name != "width";
        let filterNotAssignedByLogic = (layer: Types.layer, (parameterName, _)) =>
          switch (Layer.LayerMap.find_opt(layer, assignments)) {
          | None => true
          | Some(parameters) =>
            switch (StringMap.find_opt(parameterName, parameters)) {
            | None => true
            | Some(_) => false
            }
          };
        let defineInitialLayerValues = (layer: Types.layer) =>
          layer.parameters
          |> StringMap.bindings
          |> List.filter(filterParameters)
          |> List.filter(filterNotAssignedByLogic(layer))
          |> List.map(((k, v)) => defineInitialLayerValue(layer, (k, v)));
        rootLayer |> Layer.flatten |> List.map(defineInitialLayerValues) |> List.concat
      };
      let addSubviews = (parent: option(Types.layer), layer: Types.layer) =>
        switch parent {
        | None => []
        | Some(parent) => [
            FunctionCallExpression({
              "name": layerMemberExpression(parent, [SwiftIdentifier("addSubview")]),
              "arguments": [SwiftIdentifier(layer.name |> Format.layerName)]
            })
          ]
        };
      FunctionDeclaration({
        "name": "setUpViews",
        "modifiers": [AccessLevelModifier(PrivateModifier)],
        "parameters": [],
        "body":
          Document.joinGroups(
            Empty,
            [Layer.flatmapParent(addSubviews, root) |> List.concat, setUpDefaultsDoc()]
          )
      })
    };
    let getConstraints = (root: Types.layer) => {
      let setUpContraint =
          (layer: Types.layer, anchor1, parent: Types.layer, anchor2, relation, value, suffix) => {
        let variableName =
          (
            layer === rootLayer ?
              anchor1 : Format.layerName(layer.name) ++ Format.upperFirst(anchor1)
          )
          ++ suffix;
        let initialValue =
          MemberExpression([
            SwiftIdentifier(layer.name |> Format.layerName),
            SwiftIdentifier(anchor1),
            FunctionCallExpression({
              "name": SwiftIdentifier("constraint"),
              "arguments": [
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier(relation)),
                  "value": layerMemberExpression(parent, [SwiftIdentifier(anchor2)])
                }),
                FunctionCallArgument({"name": Some(SwiftIdentifier("constant")), "value": value})
              ]
            })
          ]);
        {variableName, initialValue, priority: Required}
      };
      let setUpLessThanOrEqualToContraint =
          (layer: Types.layer, anchor1, parent: Types.layer, anchor2, value, suffix) => {
        let variableName =
          (
            layer === rootLayer ?
              anchor1 : Format.layerName(layer.name) ++ Format.upperFirst(anchor1)
          )
          ++ suffix;
        let initialValue =
          MemberExpression([
            SwiftIdentifier(layer.name |> Format.layerName),
            SwiftIdentifier(anchor1),
            FunctionCallExpression({
              "name": SwiftIdentifier("constraint"),
              "arguments": [
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier("lessThanOrEqualTo")),
                  "value": layerMemberExpression(parent, [SwiftIdentifier(anchor2)])
                }),
                FunctionCallArgument({"name": Some(SwiftIdentifier("constant")), "value": value})
              ]
            })
          ]);
        {variableName, initialValue, priority: Low}
      };
      let setUpDimensionContraint = (layer: Types.layer, anchor, constant) => {
        let variableName =
          (
            layer === rootLayer ?
              anchor : Format.layerName(layer.name) ++ Format.upperFirst(anchor)
          )
          ++ "Constraint";
        let initialValue =
          layerMemberExpression(
            layer,
            [
              SwiftIdentifier(anchor),
              FunctionCallExpression({
                "name": SwiftIdentifier("constraint"),
                "arguments": [
                  FunctionCallArgument({
                    "name": Some(SwiftIdentifier("equalToConstant")),
                    "value": LiteralExpression(FloatingPoint(constant))
                  })
                ]
              })
            ]
          );
        {variableName, initialValue, priority: Required}
      };
      let negateNumber = (expression) =>
        PrefixExpression({"operator": "-", "expression": expression});
      let constraintConstantExpression =
          (layer: Types.layer, variable1, parent: Types.layer, variable2) => {
        let variableName = (layer: Types.layer, variable) =>
          layer === rootLayer ?
            variable : Format.layerName(layer.name) ++ Format.upperFirst(variable);
        BinaryExpression({
          "left": SwiftIdentifier(variableName(layer, variable1)),
          "operator": "+",
          "right": SwiftIdentifier(variableName(parent, variable2))
        })
      };
      let constrainAxes = (layer: Types.layer) => {
        let direction = Layer.getFlexDirection(layer);
        let primaryBeforeAnchor = direction == "column" ? "topAnchor" : "leadingAnchor";
        let primaryAfterAnchor = direction == "column" ? "bottomAnchor" : "trailingAnchor";
        let secondaryBeforeAnchor = direction == "column" ? "leadingAnchor" : "topAnchor";
        let secondaryAfterAnchor = direction == "column" ? "trailingAnchor" : "bottomAnchor";
        let height = Layer.getNumberParameterOpt("height", layer);
        let width = Layer.getNumberParameterOpt("width", layer);
        let primaryDimension = direction == "column" ? "height" : "width";
        let secondaryDimension = direction == "column" ? "width" : "height";
        let secondaryDimensionAnchor = secondaryDimension ++ "Anchor";
        /* let primaryDimensionValue = direction == "column" ? height : width; */
        /* let secondaryDimensionValue = direction == "column" ? width : height; */
        let sizingRules = layer |> Layer.getSizingRules(Layer.findParent(rootLayer, layer));
        let primarySizingRule = direction == "column" ? sizingRules.height : sizingRules.width;
        let secondarySizingRule = direction == "column" ? sizingRules.width : sizingRules.height;
        let flexChildren =
          layer.children
          |> List.filter((child: Types.layer) => Layer.getNumberParameter("flex", child) === 1.0);
        let addConstraints = (index, child: Types.layer) => {
          let childSizingRules = child |> Layer.getSizingRules(Some(layer));
          /* let childPrimarySizingRule =
            direction == "column" ? childSizingRules.height : childSizingRules.width; */
          let childSecondarySizingRule =
            direction == "column" ? childSizingRules.width : childSizingRules.height;
          let firstViewConstraints =
            switch index {
            | 0 =>
              let primaryBeforeConstant =
                direction == "column" ?
                  constraintConstantExpression(layer, "topPadding", child, "topMargin") :
                  constraintConstantExpression(layer, "leadingPadding", child, "leadingMargin");
              [
                setUpContraint(
                  child,
                  primaryBeforeAnchor,
                  layer,
                  primaryBeforeAnchor,
                  "equalTo",
                  primaryBeforeConstant,
                  "Constraint"
                )
              ]
            | _ => []
            };
          let lastViewConstraints =
            switch index {
            | x when x == List.length(layer.children) - 1 =>
              /* If the parent view has a fixed dimension, we don't need to add a constraint...
                 unless any child has "flex: 1", in which case we do still need the constraint. */
              let needsPrimaryAfterConstraint =
                switch (primarySizingRule, List.length(flexChildren)) {
                /* | (FitContent, _) => false */
                | (Fill, count) when count == 0 => false
                | (Fixed(_), count) when count == 0 => false
                | (_, _) => true
                };
              /* let needsPrimaryAfterConstraint =
                 Layer.getNumberParameterOpt(primaryDimension, layer) == None
                 || List.length(flexChildren) > 0; */
              let primaryAfterConstant =
                direction == "column" ?
                  constraintConstantExpression(layer, "bottomPadding", child, "bottomMargin") :
                  constraintConstantExpression(layer, "trailingPadding", child, "trailingMargin");
              needsPrimaryAfterConstraint ?
                [
                  setUpContraint(
                    child,
                    primaryAfterAnchor,
                    layer,
                    primaryAfterAnchor,
                    "equalTo",
                    negateNumber(primaryAfterConstant),
                    "Constraint"
                  )
                ] :
                []
            | _ => []
            };
          let middleViewConstraints =
            switch index {
            | 0 => []
            | _ =>
              let previousLayer = List.nth(layer.children, index - 1);
              let betweenConstant =
                direction == "column" ?
                  constraintConstantExpression(previousLayer, "bottomMargin", child, "topMargin") :
                  constraintConstantExpression(
                    previousLayer,
                    "trailingMargin",
                    child,
                    "leadingMargin"
                  );
              [
                setUpContraint(
                  child,
                  primaryBeforeAnchor,
                  previousLayer,
                  primaryAfterAnchor,
                  "equalTo",
                  betweenConstant,
                  "Constraint"
                )
              ]
            };
          let secondaryBeforeConstant =
            direction == "column" ?
              constraintConstantExpression(layer, "leadingPadding", child, "leadingMargin") :
              constraintConstantExpression(layer, "topPadding", child, "topMargin");
          let secondaryAfterConstant =
            direction == "column" ?
              constraintConstantExpression(layer, "trailingPadding", child, "trailingMargin") :
              constraintConstantExpression(layer, "bottomPadding", child, "bottomMargin");
          let secondaryBeforeConstraint =
            setUpContraint(
              child,
              secondaryBeforeAnchor,
              layer,
              secondaryBeforeAnchor,
              "equalTo",
              secondaryBeforeConstant,
              "Constraint"
            );
          let secondaryAfterConstraint =
            switch (secondarySizingRule, childSecondarySizingRule) {
            | (_, Fixed(_)) => [] /* Width/height constraints are added outside the child loop */
            | (_, Fill) => [
                setUpContraint(
                  child,
                  secondaryAfterAnchor,
                  layer,
                  secondaryAfterAnchor,
                  "equalTo",
                  negateNumber(secondaryAfterConstant),
                  "Constraint"
                )
              ]
            | (Fill, FitContent) =>
              [
                setUpContraint(
                  child,
                  secondaryAfterAnchor,
                  layer,
                  secondaryAfterAnchor,
                  "lessThanOrEqualTo",
                  negateNumber(secondaryAfterConstant),
                  "Constraint"
                )
              ]
            | (_, FitContent) =>
              [
                setUpContraint(
                  child,
                  secondaryAfterAnchor,
                  layer,
                  secondaryAfterAnchor,
                  "equalTo",
                  negateNumber(secondaryAfterConstant),
                  "Constraint"
                )
              ]
            };
          /* If the parent's secondary axis is set to "fit content", this ensures
             the secondary axis dimension is greater than every child's.
             We apply these in the child loop for easier variable naming (due to current setup). */
          /*
             We need these constraints to be low priority. A "FitContent" view needs height >= each
             of its children. Yet a "Fill" sibling needs to have height unspecified, and
             a side anchor equal to the side of the "FitContent" view.
             This layout is ambiguous (I think), despite no warnings at runtime. The "FitContent" view's
             height constraints seem to take priority over the "Fill" view's height constraints, and the
             "FitContent" view steals the height of the "Fill" view. We solve this by lowering the priority
             of the "FitContent" view's height.
           */
          let fitContentSecondaryConstraint =
            switch secondarySizingRule {
            | FitContent => [
                setUpLessThanOrEqualToContraint(
                  child,
                  secondaryDimensionAnchor,
                  layer,
                  secondaryDimensionAnchor,
                  negateNumber(
                    BinaryExpression({
                      "left": secondaryBeforeConstant,
                      "operator": "+",
                      "right": secondaryAfterConstant
                    })
                  ),
                  "ParentConstraint"
                )
              ]
            | _ => []
            };
          firstViewConstraints
          @ lastViewConstraints
          @ middleViewConstraints
          @ [secondaryBeforeConstraint]
          @ secondaryAfterConstraint
          @ fitContentSecondaryConstraint
        };
        /* Children with "flex: 1" should all have equal dimensions along the primary axis */
        let flexChildrenConstraints =
          switch flexChildren {
          | [first, ...rest] when List.length(rest) > 0 =>
            let sameAnchor = primaryDimension ++ "Anchor";
            let sameAnchorConstraint = (anchor, index, layer) =>
              setUpContraint(
                first,
                anchor,
                layer,
                anchor,
                "equalTo",
                LiteralExpression(FloatingPoint(0.0)),
                "SiblingConstraint" ++ string_of_int(index)
              );
            rest |> List.mapi(sameAnchorConstraint(sameAnchor))
          | _ => []
          };
        let heightConstraint =
          switch height {
          | Some(height) => [setUpDimensionContraint(layer, "heightAnchor", height)]
          | None => []
          };
        let widthConstraint =
          switch width {
          | Some(width) => [setUpDimensionContraint(layer, "widthAnchor", width)]
          | None => []
          };
        let constraints =
          [heightConstraint, widthConstraint]
          @ [flexChildrenConstraints]
          @ (layer.children |> List.mapi(addConstraints));
        constraints |> List.concat
      };
      root |> Layer.flatmap(constrainAxes) |> List.concat
    };
    let constraints = getConstraints(rootLayer);
    let setUpConstraintsDoc = (root: Types.layer) => {
      let translatesAutoresizingMask = (layer: Types.layer) =>
        BinaryExpression({
          "left":
            layerMemberExpression(
              layer,
              [SwiftIdentifier("translatesAutoresizingMaskIntoConstraints")]
            ),
          "operator": "=",
          "right": LiteralExpression(Boolean(false))
        });
      let defineConstraint = (def) =>
        ConstantDeclaration({
          "modifiers": [],
          "init": Some(def.initialValue),
          "pattern": IdentifierPattern({"identifier": def.variableName, "annotation": None})
        });
      let setConstraintPriority = (def) =>
        BinaryExpression({
          "left":
            MemberExpression([SwiftIdentifier(def.variableName), SwiftIdentifier("priority")]),
          "operator": "=",
          "right":
            MemberExpression([
              SwiftIdentifier("UILayoutPriority"),
              SwiftIdentifier(priorityName(def.priority))
            ])
        });
      let activateConstraints = () =>
        FunctionCallExpression({
          "name":
            MemberExpression([SwiftIdentifier("NSLayoutConstraint"), SwiftIdentifier("activate")]),
          "arguments": [
            FunctionCallArgument({
              "name": None,
              "value":
                LiteralExpression(
                  Array(constraints |> List.map((def) => SwiftIdentifier(def.variableName)))
                )
            })
          ]
        });
      let assignConstraint = (def) =>
        BinaryExpression({
          "left": MemberExpression([SwiftIdentifier("self"), SwiftIdentifier(def.variableName)]),
          "operator": "=",
          "right": SwiftIdentifier(def.variableName)
        });
      let assignConstraintIdentifier = (def) =>
        BinaryExpression({
          "left":
            MemberExpression([SwiftIdentifier(def.variableName), SwiftIdentifier("identifier")]),
          "operator": "=",
          "right": LiteralExpression(String(def.variableName))
        });
      FunctionDeclaration({
        "name": "setUpConstraints",
        "modifiers": [AccessLevelModifier(PrivateModifier)],
        "parameters": [],
        "body":
          List.concat([
            root |> Layer.flatmap(translatesAutoresizingMask),
            [Empty],
            constraints |> List.map(defineConstraint),
            constraints
            |> List.filter((def) => def.priority == Low)
            |> List.map(setConstraintPriority),
            [Empty],
            [activateConstraints()],
            [Empty],
            constraints |> List.map(assignConstraint),
            [LineComment("For debugging")],
            constraints |> List.map(assignConstraintIdentifier)
          ])
      })
    };
    let updateDoc = () => {
      /* let printStringBinding = ((key, value)) => Js.log2(key, value);
         let printLayerBinding = ((key: Types.layer, value)) => {
           Js.log(key.name);
           StringMap.bindings(value) |> List.iter(printStringBinding)
         };
         Layer.LayerMap.bindings(assignments) |> List.iter(printLayerBinding); */
      /* let cond = Logic.conditionallyAssignedIdentifiers(logic);
         cond |> Logic.IdentifierSet.elements |> List.iter(((ltype, path)) => Js.log(path)); */
      /* TODO: Figure out how to handle images */
      let filterParameters = ((name, _)) => name != "image" && name != "textStyle";
      let conditionallyAssigned = Logic.conditionallyAssignedIdentifiers(logic);
      let filterConditionallyAssigned = (layer: Types.layer, (name, _)) => {
        let isAssigned = ((_, value)) => value == ["layers", layer.name, name];
        conditionallyAssigned |> Logic.IdentifierSet.exists(isAssigned)
      };
      let defineInitialLayerValues = ((layer, propertyMap)) =>
        propertyMap
        |> StringMap.bindings
        |> List.filter(filterParameters)
        |> List.filter(filterConditionallyAssigned(layer))
        |> List.map(defineInitialLayerValue(layer));
      FunctionDeclaration({
        "name": "update",
        "modifiers": [AccessLevelModifier(PrivateModifier)],
        "parameters": [],
        "body":
          Document.joinGroups(
            Empty,
            [
              assignments
              |> Layer.LayerMap.bindings
              |> List.map(defineInitialLayerValues)
              |> List.concat,
              SwiftLogic.toSwiftAST(colors, rootLayer, logic)
            ]
          )
      })
    };
    TopLevelDeclaration({
      "statements": [
        ImportDeclaration("UIKit"),
        ImportDeclaration("Foundation"),
        LineComment("MARK: - " ++ name),
        Empty,
        ClassDeclaration({
          "name": name,
          "inherits": [TypeName("UIView")],
          "modifier": Some(PublicModifier),
          "isFinal": false,
          "body":
            List.concat([
              [LineComment("MARK: Lifecycle")],
              [Empty],
              [initializerDoc()],
              [Empty],
              [initializerCoderDoc()],
              [LineComment("MARK: Public")],
              [Empty],
              parameters |> List.map(parameterVariableDoc),
              [LineComment("MARK: Private")],
              [Empty],
              nonRootLayers |> List.map(viewVariableDoc),
              [Empty],
              rootLayer |> Layer.flatmap(spacingVariableDoc) |> List.concat,
              [Empty],
              constraints |> List.map((def) => constraintVariableDoc(def.variableName)),
              [Empty],
              [setUpViewsDoc(rootLayer)],
              [Empty],
              [setUpConstraintsDoc(rootLayer)],
              [Empty],
              [updateDoc()]
            ])
        })
      ]
    })
  };
};
