let equatableParameters =
    (config: Config.t, parameters: list(Types.parameter))
    : list(Types.parameter) =>
  parameters |> List.filter(SwiftComponentParameter.isEquatable(config));

let sortedParameters =
    (config: Config.t, parameters: list(Types.parameter))
    : list(Types.parameter) =>
  parameters
  |> List.sort((a, b) =>
       switch (
         SwiftComponentParameter.isFunction(config, a),
         SwiftComponentParameter.isFunction(config, b),
       ) {
       | (true, false) => 1
       | (false, false)
       | (true, true) => 0
       | (false, true) => (-1)
       }
     );

let equatableFunction =
    (config: Config.t, parameters: list(Types.parameter)): SwiftAst.node =>
  SwiftAst.(
    FunctionDeclaration({
      "name": "==",
      "attributes": [],
      "modifiers": [AccessLevelModifier(PublicModifier), StaticModifier],
      "parameters": [
        Parameter({
          "externalName": None,
          "localName": "lhs",
          "defaultValue": None,
          "annotation": TypeName("Parameters"),
        }),
        Parameter({
          "externalName": None,
          "localName": "rhs",
          "defaultValue": None,
          "annotation": TypeName("Parameters"),
        }),
      ],
      "throws": false,
      "result": Some(TypeName("Bool")),
      "body": [
        ReturnStatement(
          Some(
            switch (equatableParameters(config, parameters)) {
            | [] => LiteralExpression(Boolean(true))
            | parameters =>
              SwiftDocument.binaryExpressionList(
                "&&",
                parameters
                |> List.map((parameter: Types.parameter) =>
                     BinaryExpression({
                       "left":
                         MemberExpression([
                           SwiftIdentifier("lhs"),
                           SwiftIdentifier(
                             ParameterKey.toString(parameter.name),
                           ),
                         ]),
                       "operator": "==",
                       "right":
                         MemberExpression([
                           SwiftIdentifier("rhs"),
                           SwiftIdentifier(
                             ParameterKey.toString(parameter.name),
                           ),
                         ]),
                     })
                   ),
              )
            },
          ),
        ),
      ],
    })
  );

let memberVariableDeclaration =
    (config: Config.t, param: Types.parameter): SwiftAst.node =>
  SwiftAst.(
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier(ParameterKey.toString(param.name)),
          "annotation":
            Some(param.ltype |> SwiftDocument.typeAnnotationDoc(config)),
        }),
      "init": None,
      "block": None,
    })
  );

let initParameter = (config: Config.t, param: Types.parameter) =>
  SwiftAst.(
    Parameter({
      "externalName": None,
      "localName": param.name |> ParameterKey.toString,
      "annotation": param.ltype |> SwiftDocument.typeAnnotationDoc(config),
      "defaultValue":
        if (SwiftComponentParameter.isFunction(config, param)
            || LonaValue.isOptionalType(param.ltype)) {
          Some(LiteralExpression(Nil));
        } else {
          None;
        },
    })
  );

let initParameterAssignment = (param: Types.parameter) =>
  SwiftAst.(
    BinaryExpression({
      "left":
        SwiftAst.Builders.memberExpression([
          "self",
          param.name |> ParameterKey.toString,
        ]),
      "operator": "=",
      "right": SwiftIdentifier(param.name |> ParameterKey.toString),
    })
  );

module Parameters = {
  open SwiftAst;

  let init =
      (config: Config.t, parameters: list(Types.parameter)): SwiftAst.node =>
    InitializerDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "parameters": parameters |> List.map(initParameter(config)),
      "failable": None,
      "throws": false,
      "body": parameters |> List.map(initParameterAssignment),
    });

  let convenienceInit =
      (config: Config.t, parameters: list(Types.parameter)): SwiftAst.node =>
    InitializerDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "parameters": [],
      "failable": None,
      "throws": false,
      "body": [
        MemberExpression([
          SwiftIdentifier("self"),
          FunctionCallExpression({
            "name": SwiftIdentifier("init"),
            "arguments":
              parameters
              |> List.filter(param =>
                   !SwiftComponentParameter.isFunction(config, param)
                 )
              |> List.map((param: Decode.parameter) =>
                   FunctionCallArgument({
                     "name":
                       Some(
                         SwiftIdentifier(param.name |> ParameterKey.toString),
                       ),
                     "value":
                       SwiftDocument.defaultValueForLonaType(
                         config,
                         param.ltype,
                       ),
                   })
                 ),
          }),
        ]),
      ],
    });
};

module Model = {
  open SwiftAst;

  let init = () =>
    InitializerDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "parameters": [
        Parameter({
          "externalName": Some("_"),
          "localName": "parameters",
          "defaultValue": None,
          "annotation": TypeName("Parameters"),
        }),
      ],
      "failable": None,
      "throws": false,
      "body": [
        SwiftAst.BinaryExpression({
          "left": SwiftAst.Builders.memberExpression(["self", "parameters"]),
          "operator": "=",
          "right": SwiftIdentifier("parameters"),
        }),
      ],
    });

  let initIdParameters = () =>
    InitializerDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "parameters": [
        Parameter({
          "externalName": None,
          "localName": "id",
          "defaultValue": Some(LiteralExpression(Nil)),
          "annotation": TypeName("String?"),
        }),
        Parameter({
          "externalName": None,
          "localName": "parameters",
          "defaultValue": None,
          "annotation": TypeName("Parameters"),
        }),
      ],
      "failable": None,
      "throws": false,
      "body": [
        SwiftAst.BinaryExpression({
          "left": SwiftAst.Builders.memberExpression(["self", "id"]),
          "operator": "=",
          "right": SwiftIdentifier("id"),
        }),
        SwiftAst.BinaryExpression({
          "left": SwiftAst.Builders.memberExpression(["self", "parameters"]),
          "operator": "=",
          "right": SwiftIdentifier("parameters"),
        }),
      ],
    });

  let initWithIndividualParameters =
      (config: Config.t, parameters: list(Types.parameter)): SwiftAst.node =>
    InitializerDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "parameters": parameters |> List.map(initParameter(config)),
      "failable": None,
      "throws": false,
      "body": [
        MemberExpression([
          SwiftIdentifier("self"),
          FunctionCallExpression({
            "name": SwiftIdentifier("init"),
            "arguments": [
              FunctionCallArgument({
                "name": None,
                "value":
                  FunctionCallExpression({
                    "name": SwiftIdentifier("Parameters"),
                    "arguments":
                      parameters
                      |> List.map((param: Decode.parameter) =>
                           FunctionCallArgument({
                             "name":
                               Some(
                                 SwiftIdentifier(
                                   param.name |> ParameterKey.toString,
                                 ),
                               ),
                             "value":
                               SwiftIdentifier(
                                 param.name |> ParameterKey.toString,
                               ),
                           })
                         ),
                  }),
              }),
            ],
          }),
        ]),
      ],
    });

  let convenienceInit =
      (
        config: Config.t,
        swiftOptions: SwiftOptions.options,
        parameters: list(Types.parameter),
      )
      : SwiftAst.node =>
    InitializerDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "parameters": [],
      "failable": None,
      "throws": false,
      "body": [
        MemberExpression([
          SwiftIdentifier("self"),
          FunctionCallExpression({
            "name": SwiftIdentifier("init"),
            "arguments":
              parameters
              |> List.filter(param =>
                   !SwiftComponentParameter.isFunction(config, param)
                 )
              |> List.map((param: Decode.parameter) =>
                   FunctionCallArgument({
                     "name":
                       Some(
                         SwiftIdentifier(param.name |> ParameterKey.toString),
                       ),
                     "value":
                       SwiftDocument.defaultValueForLonaType(
                         config,
                         param.ltype,
                       ),
                   })
                 ),
          }),
        ]),
      ],
    });

  let parametersVariable = () =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier("parameters"),
          "annotation": Some(TypeName("Parameters")),
        }),
      "init": None,
      "block": None,
    });

  let idVariable = () =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier("id"),
          "annotation": Some(TypeName("String?")),
        }),
      "init": None,
      "block": None,
    });

  let typeVariable = name =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier("type"),
          "annotation": Some(TypeName("String")),
        }),
      "init": None,
      "block":
        Some(
          GetterBlock([
            ReturnStatement(Some(LiteralExpression(String(name)))),
          ]),
        ),
    });
};

let parametersStruct =
    (config: Config.t, parameters: list(Types.parameter)): SwiftAst.node => {
  let parameters = sortedParameters(config, parameters);

  SwiftAst.(
    StructDeclaration({
      "name": "Parameters",
      "inherits": [TypeName("Equatable")],
      "modifier": Some(PublicModifier),
      "body":
        [
          parameters |> List.map(memberVariableDeclaration(config)),
          [Parameters.init(config, parameters)],
          List.length(
            parameters
            |> List.filter(param =>
                 !(
                   SwiftComponentParameter.isFunction(config, param)
                   || LonaValue.isOptionalType(param.ltype)
                 )
               ),
          )
          > 0 ?
            [Parameters.convenienceInit(config, parameters)] : [],
          List.length(parameters) > 0 ?
            [equatableFunction(config, parameters)] : [],
        ]
        |> SwiftDocument.joinGroups(Empty),
    })
  );
};

let viewModelStruct =
    (
      config: Config.t,
      swiftOptions: SwiftOptions.options,
      parameters: list(Types.parameter),
      className: string,
    )
    : SwiftAst.node => {
  let parameters = sortedParameters(config, parameters);

  SwiftAst.(
    StructDeclaration({
      "name": "Model",
      "inherits": [TypeName("LonaViewModel"), TypeName("Equatable")],
      "modifier": Some(PublicModifier),
      "body":
        [
          [
            Model.idVariable(),
            Model.parametersVariable(),
            Model.typeVariable(className),
          ],
          [Model.initIdParameters()],
          [Model.init()],
          [Model.initWithIndividualParameters(config, parameters)],
          List.length(
            parameters
            |> List.filter(param =>
                 !(
                   SwiftComponentParameter.isFunction(config, param)
                   || LonaValue.isOptionalType(param.ltype)
                 )
               ),
          )
          > 0 ?
            [Model.convenienceInit(config, swiftOptions, parameters)] : [],
        ]
        |> SwiftDocument.joinGroups(Empty),
    })
  );
};

let parametersExtension =
    (
      config: Config.t,
      className: string,
      parameters: list(Types.parameter),
    )
    : list(SwiftAst.node) =>
  SwiftAst.[
    LineComment("MARK: - Parameters"),
    Empty,
    ExtensionDeclaration({
      "name": className,
      "protocols": [],
      "where": None,
      "modifier": None,
      "body": [parametersStruct(config, parameters)],
    }),
  ];

let viewModelExtension =
    (
      config: Config.t,
      swiftOptions: SwiftOptions.options,
      className: string,
      parameters: list(Types.parameter),
    )
    : list(SwiftAst.node) =>
  SwiftAst.[
    LineComment("MARK: - Model"),
    Empty,
    ExtensionDeclaration({
      "name": className,
      "protocols": [],
      "where": None,
      "modifier": None,
      "body": [viewModelStruct(config, swiftOptions, parameters, className)],
    }),
  ];