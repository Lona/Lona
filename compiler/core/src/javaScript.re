module Ast = {
  type binaryOperator =
    | Eq
    | Neq
    | Gt
    | Gte
    | Lt
    | Lte
    | Plus
    | Noop;
  type node =
    | Return(node)
    | Literal(Types.lonaValue)
    | Identifier(list(string))
    | Class(string, option(string), list(node))
    | Method(string, list(string), list(node))
    | CallExpression(node, list(node))
    | JSXAttribute(string, node)
    | JSXElement(string, list(node), list(node))
    | VariableDeclaration(node)
    | AssignmentExpression(node, node)
    | BooleanExpression(node, binaryOperator, node)
    | ConditionalStatement(node, list(node))
    | ArrayLiteral(list(node))
    | ObjectLiteral(list(node))
    | ObjectProperty(node, node)
    | Block(list(node))
    | Program(list(node))
    | Unknown;
  /* Children are mapped first */
  let rec map = (f, node) =>
    switch node {
    | Return(value) => f(Return(value |> map(f)))
    | Literal(_) => f(node)
    | Identifier(_) => f(node)
    | Class(a, b, body) => f(Class(a, b, body |> List.map(map(f))))
    | Method(a, b, body) => f(Method(a, b, body |> List.map(map(f))))
    | CallExpression(value, body) => f(CallExpression(value |> map(f), body |> List.map(map(f))))
    | JSXAttribute(a, value) => f(JSXAttribute(a, value |> map(f)))
    | JSXElement(a, attributes, body) =>
      f(JSXElement(a, attributes |> List.map(map(f)), body |> List.map(map(f))))
    | VariableDeclaration(value) => f(VariableDeclaration(value |> map(f)))
    | AssignmentExpression(value1, value2) =>
      f(AssignmentExpression(value1 |> map(f), value2 |> map(f)))
    | BooleanExpression(value1, a, value2) =>
      f(BooleanExpression(value1 |> map(f), a, value2 |> map(f)))
    | ConditionalStatement(condition, body) =>
      f(ConditionalStatement(condition |> map(f), body |> List.map(map(f))))
    | ArrayLiteral(body) => f(ArrayLiteral(body |> List.map(map(f))))
    | ObjectLiteral(body) => f(ObjectLiteral(body |> List.map(map(f))))
    | ObjectProperty(value1, value2) => f(ObjectProperty(value1 |> map(f), value2 |> map(f)))
    | Block(body) => f(Block(body |> List.map(map(f))))
    | Program(body) => f(Program(body |> List.map(map(f))))
    | Unknown => f(node)
    };
  /* Takes an expression like `a === true` and converts it to `a` */
  let optimizeTruthyBooleanExpression = (node) => {
    let booleanValue = (sub) =>
      switch sub {
      | Literal(value) => value.data |> Json.Decode.optional(Json.Decode.bool)
      | _ => (None: option(bool))
      };
    switch node {
    | BooleanExpression(a, cmp, b) =>
      let boolA = booleanValue(a);
      let boolB = booleanValue(b);
      switch (boolA, cmp, boolB) {
      | (_, Eq, Some(true)) => a
      | (Some(true), Eq, _) => b
      | _ => node
      }
    | _ => node
    }
  };
  /* Renamed "layer.View.backgroundColor" to something JS-safe and nice looking */
  let renameIdentifiers = (node) =>
    switch node {
    | Identifier([head, ...tail]) =>
      switch head {
      | "parameters" => Identifier(["this", "props", ...tail])
      | "layers" =>
        switch tail {
        | [second, ...tail] =>
          Identifier([tail |> List.fold_left((a, b) => a ++ "$" ++ b, second)])
        | _ => node
        }
      | _ => node
      }
    | _ => node
    };
  let optimize = (node) => node |> map(optimizeTruthyBooleanExpression);
  let prepareForRender = (node) => node |> map(renameIdentifiers);
};

module Render = {
  open Prettier.Doc.Builders;
  let renderBinaryOperator = (x) => {
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
    s(op)
  };
  /* Render AST */
  let rec render = (ast) : Prettier.Doc.t('a) =>
    switch ast {
    | Ast.Identifier(path) => path |> List.map(s) |> join(concat([softline, s(".")])) |> group
    | Literal(value) => s(Js.Json.stringify(value.data))
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
        indent(Render.prefixAll(hardline, body |> List.map(render))),
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
    | Block(body) => body |> List.map(render) |> Render.prefixAll(hardline)
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

let logicValueToJavaScriptAST = (x) =>
  switch x {
  | Logic.Identifier(_, path) => Ast.Identifier(path)
  | Literal(x) => Literal(x)
  | None => Unknown
  };

let rec toJavaScriptAST = (node) => {
  let fromCmp = (x) =>
    switch x {
    | Types.Eq => Ast.Eq
    | Neq => Neq
    | Gt => Gt
    | Gte => Gte
    | Lt => Lt
    | Lte => Lte
    | Unknown => Noop
    };
  switch node {
  | Logic.Assign(a, b) =>
    Ast.AssignmentExpression(logicValueToJavaScriptAST(b), logicValueToJavaScriptAST(a))
  | IfExists(a, body) =>
    ConditionalStatement(logicValueToJavaScriptAST(a), [toJavaScriptAST(body)])
  | Block(body) => Ast.Block(body |> List.map(toJavaScriptAST))
  | If(a, cmp, b, body) =>
    let condition =
      Ast.BooleanExpression(
        logicValueToJavaScriptAST(a),
        fromCmp(cmp),
        logicValueToJavaScriptAST(b)
      );
    ConditionalStatement(condition, [toJavaScriptAST(body)])
  | Add(lhs, rhs, value) =>
    let addition =
      Ast.BooleanExpression(logicValueToJavaScriptAST(lhs), Plus, logicValueToJavaScriptAST(rhs));
    AssignmentExpression(logicValueToJavaScriptAST(value), addition)
  | Let(value) =>
    switch value {
    | Identifier(_, path) => Ast.VariableDeclaration(Ast.Identifier(path))
    | _ => Unknown
    }
  | None => Unknown
  }
};

let createStyleAttributeAST = (layerName, styles) =>
  Ast.(
    JSXAttribute(
      "style",
      ArrayLiteral([
        Identifier(["styles", layerName]),
        ObjectLiteral(
          styles
          |> Layer.mapBindings(
               ((key, value)) =>
                 ObjectProperty(Identifier([key]), logicValueToJavaScriptAST(value))
             )
        )
      ])
    )
  );

let rec layerToJavaScriptAST = (variableMap, layer: Types.layer) => {
  open Ast;
  let (_, mainParams) =
    layer.parameters |> Layer.parameterMapToLogicValueMap |> Layer.splitParamsMap;
  let (styleVariables, mainVariables) =
    (
      switch (Layer.LayerMap.find_opt(layer, variableMap)) {
      | Some(map) => map
      | None => StringMap.empty
      }
    )
    |> Layer.splitParamsMap;
  let main = StringMap.assign(mainParams, mainVariables);
  let styleAttribute = createStyleAttributeAST(layer.name, styleVariables);
  let attributes =
    main
    |> Layer.mapBindings(((key, value)) => JSXAttribute(key, logicValueToJavaScriptAST(value)));
  JSXElement(
    Layer.layerTypeToString(layer.typeName),
    [styleAttribute, ...attributes],
    layer.children |> List.map(layerToJavaScriptAST(variableMap))
  )
};

let toJavaScriptStyleSheetAST = (layer: Types.layer) => {
  open Ast;
  let createStyleObjectForLayer = (layer: Types.layer) => {
    let styleParams =
      layer.parameters |> StringMap.filter((key, _) => Layer.parameterIsStyle(key));
    ObjectProperty(
      Identifier([layer.name]),
      ObjectLiteral(
        styleParams
        |> StringMap.bindings
        |> List.map(((key, value)) => ObjectProperty(Identifier([key]), Literal(value)))
      )
    )
  };
  let styleObjects = layer |> Layer.flatten |> List.map(createStyleObjectForLayer);
  VariableDeclaration(
    AssignmentExpression(
      Identifier(["styles"]),
      CallExpression(Identifier(["StyleSheet", "create"]), [ObjectLiteral(styleObjects)])
    )
  )
};

module Component = {
  let generate = (name, json) => {
    let rootLayer = json |> Decode.Component.rootLayer;
    let logic = json |> Decode.Component.logic |> Logic.addVariableDeclarations;
    let assignments = Layer.parameterAssignmentsFromLogic(rootLayer, logic);
    let rootLayerAST = rootLayer |> layerToJavaScriptAST(assignments);
    let styleSheetAST = rootLayer |> toJavaScriptStyleSheetAST;
    let logicAST = logic |> toJavaScriptAST |> Ast.optimize;
    Ast.(
      Program([
        Class(
          name,
          Some("React.Component"),
          [Method("render", [], [logicAST, Return(rootLayerAST)])]
        ),
        styleSheetAST
      ])
    )
    /* Renames variables */
    |> Ast.prepareForRender
  };
};