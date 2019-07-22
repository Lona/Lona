open LogicUtils;

let convertNativeType = (context: context, typeName: string): string =>
  switch (typeName) {
  | "Boolean" => "Bool"
  | "Number" => "CGFloat"
  | "WholeNumber" => "Int"
  | "String" => "String"
  | "Optional" => "Optional"
  | "URL" => SwiftDocument.imageTypeName(context.config)
  | "Color" => SwiftDocument.colorTypeName(context.config)
  | _ => typeName
  };

let rec convert = (config: Config.t, node: LogicAst.syntaxNode): SwiftAst.node => {
  let context = {config, isStatic: false, rootNode: node};
  switch (node) {
  | LogicAst.Program(Program(contents)) => program(context, contents)
  | LogicAst.TopLevelDeclarations(TopLevelDeclarations(contents)) =>
    topLevelDeclarations(context, contents)
  | _ =>
    Js.log("Unhandled syntaxNode type");
    Empty;
  };
}
and program = (context: context, node: LogicAst.programProgram): SwiftAst.node =>
  SwiftAst.topLevelDeclaration({
    "statements":
      node.block
      |> unfoldPairs
      |> Sequence.rejectWhere(isPlaceholderStatement)
      |> List.map(statement(context)),
  })
and topLevelDeclarations =
    (
      context: context,
      node: LogicAst.topLevelDeclarationsTopLevelDeclarations,
    )
    : SwiftAst.node =>
  SwiftAst.topLevelDeclaration({
    "statements":
      node.declarations
      |> unfoldPairs
      |> Sequence.rejectWhere(isPlaceholderDeclaration)
      |> List.map(declaration(context)),
  })
and statement = (context: context, node: LogicAst.statement): SwiftAst.node =>
  switch (node) {
  | Declaration({content}) => declaration(context, content)
  | Placeholder(_) => Empty
  | _ =>
    Js.log("Unhandled statement type");
    Empty;
  }
and declaration =
    (context: context, node: LogicAst.declaration): SwiftAst.node =>
  switch (node) {
  | ImportDeclaration(_) => Empty
  | Namespace({name: LogicAst.Pattern({name}), declarations}) =>
    let context = {...context, isStatic: true};
    SwiftAst.EnumDeclaration({
      "name": name,
      "isIndirect": true,
      "inherits": [],
      "modifier": Some(SwiftAst.PublicModifier),
      "body":
        declarations
        |> unfoldPairs
        |> Sequence.rejectWhere(isPlaceholderDeclaration)
        |> List.map(declaration(context)),
    });
  | Variable({name: LogicAst.Pattern({name}), annotation, initializer_}) =>
    SwiftAst.ConstantDeclaration({
      "modifiers":
        (context.isStatic ? [SwiftAst.StaticModifier] : [])
        @ [AccessLevelModifier(PublicModifier)],
      "pattern":
        SwiftAst.IdentifierPattern({
          "identifier": SwiftAst.SwiftIdentifier(name),
          "annotation": annotation |> Monad.map(typeAnnotation(context)),
        }),
      "init": initializer_ |> Monad.map(expression(context)),
    })
  | Record({
      name: LogicAst.Pattern({name}),
      genericParameters: _,
      declarations,
    }) =>
    let context = {...context, isStatic: false};

    let memberVariables =
      declarations
      |> unfoldPairs
      |> List.map(declaration =>
           switch (declaration) {
           | LogicAst.Variable(decl) => Some(decl)
           | _ => None
           }
         )
      |> Sequence.compact;

    let initFunction =
      SwiftAst.InitializerDeclaration({
        "modifiers": [SwiftAst.AccessLevelModifier(PublicModifier)],
        "parameters":
          memberVariables
          |> List.map((variable: LogicAst.variableDeclaration) => {
               let {
                 LogicAst.name: LogicAst.Pattern({name: labelName}),
                 annotation,
                 initializer_,
               } = variable;

               SwiftAst.Parameter({
                 "externalName": None,
                 "localName": labelName,
                 "annotation":
                   typeAnnotation(context, Monad.getExn(annotation)),
                 "defaultValue":
                   initializer_ |> Monad.map(expression(context)),
               });
             }),
        "failable": None,
        "throws": false,
        "body":
          memberVariables
          |> List.map((variable: LogicAst.variableDeclaration) => {
               let {
                 LogicAst.name: LogicAst.Pattern({name: labelName}),
                 initializer_,
               } = variable;

               SwiftAst.(
                 BinaryExpression({
                   "left":
                     SwiftAst.Builders.memberExpression(["self", labelName]),
                   "operator": "=",
                   "right": SwiftIdentifier(labelName),
                 })
               );
             }),
      });

    SwiftAst.(
      StructDeclaration({
        "name": name,
        "inherits": [TypeName("Equatable")],
        "modifier": Some(PublicModifier),
        "body":
          List.concat([
            memberVariables != [] ? [initFunction] : [],
            memberVariables
            |> List.map((variable: LogicAst.variableDeclaration) => {
                 let {LogicAst.id, name, annotation} = variable;

                 LogicAst.Variable(
                   variableBuilder(id, name, annotation, None),
                 );
               })
            |> List.map(declaration(context)),
            /* TODO: Other declarations */
          ]),
      })
    );
  | Enumeration({name: LogicAst.Pattern({name}), genericParameters, cases}) =>
    EnumDeclaration({
      "name": name,
      "isIndirect": true,
      "inherits":
        genericParameters
        |> unfoldPairs
        |> List.map(genericParameter(context)),
      "modifier": Some(SwiftAst.PublicModifier),
      "body":
        cases
        |> unfoldPairs
        |> List.map((enumCase: LogicAst.enumerationCase) =>
             switch (enumCase) {
             | Placeholder(_) => None
             | EnumerationCase(value) => Some(value)
             }
           )
        |> Sequence.compact
        |> List.map((enumCase: LogicAst.enumerationCaseEnumerationCase) => {
             let {LogicAst.name: Pattern({name}), associatedValueTypes} = enumCase;

             let associatedValueTypes =
               associatedValueTypes
               |> unfoldPairs
               |> Sequence.rejectWhere(isPlaceholderTypeAnnotation);

             let associatedType =
               switch (associatedValueTypes) {
               | [] => None
               | valueTypes =>
                 let elements: list(SwiftAst.tupleTypeElement) =
                   valueTypes
                   |> List.map((associatedType: LogicAst.typeAnnotation) =>
                        SwiftAst.makeTupleElement(
                          None,
                          typeAnnotation(context, associatedType),
                        )
                      );
                 Some(SwiftAst.TupleType(elements));
               };

             SwiftAst.EnumCase({
               "name": SwiftAst.SwiftIdentifier(name),
               "parameters": associatedType,
               "value": None,
             });
           }),
    })
  | Placeholder(_) => Empty
  | _ =>
    Js.log("Unhandled declaration type");
    Empty;
  }
and expression = (context: context, node: LogicAst.expression): SwiftAst.node =>
  switch (node) {
  | IdentifierExpression({
      identifier: Identifier({string: name, isPlaceholder: _}),
    }) =>
    SwiftIdentifier(name)
  | LiteralExpression({literal: value}) => literal(context, value)
  | MemberExpression({
      memberName: Identifier({string}),
      expression: innerExpression,
    }) =>
    SwiftAst.memberExpression([
      expression(context, innerExpression),
      SwiftAst.SwiftIdentifier(string),
    ])
  | FunctionCallExpression({arguments, expression: innerExpression}) =>
    SwiftAst.FunctionCallExpression({
      "name": expression(context, innerExpression),
      "arguments":
        arguments
        |> unfoldPairs
        |> List.map((arg: LogicAst.functionCallArgument) => {
             let LogicAst.FunctionCallArgument({
                   label,
                   expression: innerExpression,
                 }) = arg;
             SwiftAst.FunctionCallArgument({
               "name":
                 label |> Monad.map(str => SwiftAst.SwiftIdentifier(str)),
               "value": expression(context, innerExpression),
             });
           }),
    })
  | Placeholder(_) =>
    Js.log("Placeholder expression remaining");
    Empty;
  | _ =>
    Js.log("Unhandled expression type");
    Empty;
  }
and literal = (context: context, node: LogicAst.literal): SwiftAst.node =>
  switch (node) {
  | None(_) => SwiftAst.LiteralExpression(Nil)
  | Boolean({value}) => SwiftAst.LiteralExpression(Boolean(value))
  | Number({value}) => SwiftAst.LiteralExpression(FloatingPoint(value))
  | String({value}) => SwiftAst.LiteralExpression(String(value))
  | Color({value}) => SwiftAst.LiteralExpression(Color(value))
  | Array({value}) =>
    SwiftAst.LiteralExpression(
      Array(value |> unfoldPairs |> List.map(expression(context))),
    )
  }
and typeAnnotation =
    (context: context, node: LogicAst.typeAnnotation): SwiftAst.typeAnnotation =>
  switch (node) {
  | TypeIdentifier({
      identifier: Identifier({string: name, isPlaceholder: _}),
      genericArguments: Empty,
    }) =>
    TypeName(convertNativeType(context, name))
  | Placeholder(_) =>
    Js.log("Type placeholder remaining in file");
    TypeName("_");
  | _ =>
    Js.log("Unhandled type annotation");
    TypeName("_");
  }
and genericParameter =
    (context: context, node: LogicAst.genericParameter)
    : SwiftAst.typeAnnotation =>
  switch (node) {
  | Parameter({name: LogicAst.Pattern({name})}) =>
    TypeName(convertNativeType(context, name))
  | Placeholder(_) =>
    Js.log("Generic type placeholder remaining in file");
    TypeName("_");
  };