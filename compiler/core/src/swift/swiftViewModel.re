/* switch (parameter.ltype) {
   | Function(_) => false
   | _ => true
   }; */

let equatableParameters =
    (parameters: list(Types.parameter)): list(Types.parameter) =>
  parameters |> List.filter(SwiftComponentParameter.isEquatable);

let sortedParameters =
    (parameters: list(Types.parameter)): list(Types.parameter) =>
  parameters
  |> List.sort((a, b) =>
       switch (
         SwiftComponentParameter.isFunction(a),
         SwiftComponentParameter.isFunction(b),
       ) {
       | (true, false) => 1
       | (false, false)
       | (true, true) => 0
       | (false, true) => (-1)
       }
     );

let equatableFunction =
    (_swiftOptions: SwiftOptions.options, parameters: list(Types.parameter))
    : SwiftAst.node =>
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
            switch (equatableParameters(parameters)) {
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
    (swiftOptions: SwiftOptions.options, param: Types.parameter)
    : SwiftAst.node =>
  SwiftAst.(
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier(ParameterKey.toString(param.name)),
          "annotation":
            Some(
              param.ltype
              |> SwiftDocument.typeAnnotationDoc(swiftOptions.framework),
            ),
        }),
      "init": None,
      "block": None,
    })
  );

let initParameter =
    (swiftOptions: SwiftOptions.options, param: Types.parameter) =>
  SwiftAst.(
    Parameter({
      "externalName": None,
      "localName": param.name |> ParameterKey.toString,
      "annotation":
        param.ltype |> SwiftDocument.typeAnnotationDoc(swiftOptions.framework),
      "defaultValue":
        if (SwiftComponentParameter.isFunction(param)
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

let init =
    (swiftOptions: SwiftOptions.options, parameters: list(Types.parameter))
    : SwiftAst.node =>
  SwiftAst.(
    InitializerDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "parameters": parameters |> List.map(initParameter(swiftOptions)),
      "failable": None,
      "throws": false,
      "body": parameters |> List.map(initParameterAssignment),
    })
  );

let convenienceInit =
    (
      config: Config.t,
      swiftOptions: SwiftOptions.options,
      parameters: list(Types.parameter),
    )
    : SwiftAst.node =>
  SwiftAst.(
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
                   !SwiftComponentParameter.isFunction(param)
                 )
              |> List.map((param: Decode.parameter) =>
                   FunctionCallArgument({
                     "name":
                       Some(
                         SwiftIdentifier(param.name |> ParameterKey.toString),
                       ),
                     "value":
                       SwiftDocument.defaultValueForLonaType(
                         swiftOptions.framework,
                         config,
                         param.ltype,
                       ),
                   })
                 ),
          }),
        ]),
      ],
    })
  );

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

  let initWithIndividualParameters =
      (swiftOptions: SwiftOptions.options, parameters: list(Types.parameter))
      : SwiftAst.node =>
    InitializerDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "parameters": parameters |> List.map(initParameter(swiftOptions)),
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
    (
      config: Config.t,
      swiftOptions: SwiftOptions.options,
      parameters: list(Types.parameter),
    )
    : SwiftAst.node => {
  let parameters = sortedParameters(parameters);

  SwiftAst.(
    StructDeclaration({
      "name": "Parameters",
      "inherits": [TypeName("Equatable")],
      "modifier": Some(PublicModifier),
      "body":
        [
          parameters |> List.map(memberVariableDeclaration(swiftOptions)),
          [init(swiftOptions, parameters)],
          List.length(
            parameters
            |> List.filter(param =>
                 !(
                   SwiftComponentParameter.isFunction(param)
                   || LonaValue.isOptionalType(param.ltype)
                 )
               ),
          )
          > 0 ?
            [convenienceInit(config, swiftOptions, parameters)] : [],
          List.length(parameters) > 0 ?
            [equatableFunction(swiftOptions, parameters)] : [],
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
  let parameters = sortedParameters(parameters);

  SwiftAst.(
    StructDeclaration({
      "name": "Model",
      "inherits": [TypeName("LonaViewModel"), TypeName("Equatable")],
      "modifier": Some(PublicModifier),
      "body":
        [
          [Model.parametersVariable(), Model.typeVariable(className)],
          [Model.init()],
          [Model.initWithIndividualParameters(swiftOptions, parameters)],
          List.length(
            parameters
            |> List.filter(param =>
                 !(
                   SwiftComponentParameter.isFunction(param)
                   || LonaValue.isOptionalType(param.ltype)
                 )
               ),
          )
          > 0 ?
            [convenienceInit(config, swiftOptions, parameters)] : [],
        ]
        |> SwiftDocument.joinGroups(Empty),
    })
  );
};

let parametersExtension =
    (
      config: Config.t,
      swiftOptions: SwiftOptions.options,
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
      "body": [parametersStruct(config, swiftOptions, parameters)],
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