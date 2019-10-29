open Operators;
open ReasonAst;

type conversionOptions = {nativeTypeNames: list(string)};

let definesCustomListType = false;

let formatNativeType = string =>
  switch (string) {
  | "UUID" => Some("string")
  | "Bool" => Some("bool")
  | "CGFloat" => Some("float")
  | "String" => Some("string")
  | "Optional" => Some("option")
  | "Array" => definesCustomListType ? None : Some("list")
  | _ => None
  };

let formatDecoderIdentifier = string =>
  switch (string) {
  | "bool" => "Json.Decode.bool"
  | "float" => "Json.Decode.float"
  | "string" => "Json.Decode.string"
  | "option" => "Json.Decode.optional"
  | "list" when !definesCustomListType => "Json.Decode.list"
  | _ => string
  };

let formatTypeName = string =>
  formatNativeType(string) %? Format.lowerFirst(string);
let formatCaseName = (name: string) =>
  if (Js.Re.test(name, Js.Re.fromString("^\\d"))) {
    Format.upperFirst("X" ++ name);
  } else {
    Format.upperFirst(name);
  };
let formatRecordTypeName = (name, parent) =>
  Format.lowerFirst(name) ++ Format.upperFirst(parent);
let formatGenericName = string => "'" ++ Format.lowerFirst(string);

type renderedTypeCaseParameter = {
  annotation: typeAnnotation,
  decoder: expression,
};

let placeholderExpression = LiteralExpression({literal: String("...")});
let identityFunction =
  FunctionExpression({
    parameters: [{name: "x", annotation: None}],
    returnType: None,
    body: [Expression(IdentifierExpression({name: "x"}))],
  });

let linkedListReducerFunction =
    (functionName: string, tupleCase: expression, emptyCase: expression)
    : declaration =>
  Variable([
    {
      name: functionName,
      quantifiedAnnotation: None,
      initializer_:
        FunctionExpression({
          parameters: [{name: "items", annotation: None}],
          returnType: None,
          body: [
            Expression(
              SwitchExpression({
                pattern: IdentifierExpression({name: "items"}),
                cases: [
                  {
                    pattern: LiteralExpression({literal: Array([])}),
                    body: [Expression(emptyCase)],
                  },
                  {
                    pattern:
                      LiteralExpression({
                        literal: Array([IdentifierExpression({name: "a"})]),
                      }),
                    body: [
                      Expression(
                        FunctionCallExpression({
                          expression: tupleCase,
                          arguments: [
                            IdentifierExpression({name: "a"}),
                            emptyCase,
                          ],
                        }),
                      ),
                    ],
                  },
                  {
                    pattern:
                      LiteralExpression({
                        literal:
                          Array([
                            IdentifierExpression({name: "a"}),
                            IdentifierExpression({name: "...rest"}),
                          ]),
                      }),
                    body: [
                      Expression(
                        FunctionCallExpression({
                          expression: tupleCase,
                          arguments: [
                            IdentifierExpression({name: "a"}),
                            FunctionCallExpression({
                              expression:
                                IdentifierExpression({name: functionName}),
                              arguments: [
                                IdentifierExpression({name: "rest"}),
                              ],
                            }),
                          ],
                        }),
                      ),
                    ],
                  },
                ],
              }),
            ),
          ],
        }),
    },
  ]);

let typeAnnotationForEntity =
    (_options: conversionOptions, entity: TypeSystem.entity): typeAnnotation => {
  let genericTypeNames = TypeSystem.Access.entityGenericParameters(entity);
  let genericTypeAnnotations: list(typeAnnotation) =
    genericTypeNames
    |> List.map(name => {name: formatGenericName(name), parameters: []});

  switch (entity) {
  | GenericType(genericType) =>
    /* TODO: pass down entity instead of type annotation
       refactor, make function to get type annotation easily */
    let typeName = formatTypeName(genericType.name);
    {name: typeName, parameters: genericTypeAnnotations};
  | NativeType(nativeType) =>
    let typeName = formatTypeName(nativeType.name);
    {name: typeName, parameters: genericTypeAnnotations};
  };
};

let renderTypeCaseParameterEntity =
    (
      options: conversionOptions,
      entity: TypeSystem.entity,
      typeCaseParameterEntity: TypeSystem.typeCaseParameterEntity,
    )
    : renderedTypeCaseParameter => {
  let genericTypeNames = TypeSystem.Access.entityGenericParameters(entity);
  let entityTypeAnnotation = typeAnnotationForEntity(options, entity);
  switch (typeCaseParameterEntity) {
  | TypeReference(name, substitutions) =>
    let typeName = formatTypeName(name);

    if (typeName == entityTypeAnnotation.name) {
      {
        annotation: entityTypeAnnotation,
        decoder:
          FunctionCallExpression({
            expression:
              IdentifierExpression({
                name: formatDecoderIdentifier(entityTypeAnnotation.name),
              }),
            arguments:
              genericTypeNames
              |> List.map(name => formatDecoderIdentifier(name))
              |> List.map(name =>
                   IdentifierExpression({name: "decoder" ++ name})
                 ),
          }),
      };
    } else {
      let replacedGenerics: list(typeAnnotation) =
        substitutions
        |> List.map(
             (substitution: TypeSystem.genericTypeParameterSubstitution) =>
             formatTypeName(substitution.instance)
           )
        |> List.map(name => {name, parameters: []});
      {
        annotation: {
          name: typeName,
          parameters: replacedGenerics,
        },
        decoder:
          if (replacedGenerics == []) {
            IdentifierExpression({name: formatDecoderIdentifier(typeName)});
          } else {
            FunctionCallExpression({
              expression:
                IdentifierExpression({
                  name: formatDecoderIdentifier(typeName),
                }),
              arguments:
                replacedGenerics
                |> List.map((annotation: typeAnnotation) => annotation.name)
                |> List.map(name =>
                     IdentifierExpression({
                       name: formatDecoderIdentifier(name),
                     })
                   ),
            });
          },
      };
    };
  | GenericReference(name) => {
      annotation: {
        name: formatGenericName(name),
        parameters: [],
      },
      decoder: IdentifierExpression({name: "decoder" ++ name}),
    }
  };
};

type renderedRecordTypeCaseParameter = {
  entry: recordTypeEntry,
  decoder: expression,
};

let renderRecordTypeCaseParameter =
    (
      options: conversionOptions,
      entityTypeAnnotation: TypeSystem.entity,
      fieldName: string,
      entity: TypeSystem.recordTypeCaseParameter,
    )
    : renderedRecordTypeCaseParameter => {
  let isOptional =
    TypeSystem.Access.typeCaseParameterEntityName(entity.value) == "Optional";

  let rendered =
    renderTypeCaseParameterEntity(
      options,
      entityTypeAnnotation,
      entity.value,
    );
  {
    entry: {
      key: entity.key,
      value: rendered.annotation,
    },
    decoder:
      if (isOptional) {
        FunctionCallExpression({
          expression: IdentifierExpression({name: "Json.Decode.optional"}),
          arguments: [
            FunctionCallExpression({
              expression: IdentifierExpression({name: "Json.Decode.field"}),
              arguments: [
                LiteralExpression({literal: String(entity.key)}),
                IdentifierExpression({
                  name:
                    rendered.annotation.parameters
                    |> List.map((parameter: typeAnnotation) =>
                         formatDecoderIdentifier(parameter.name)
                       )
                    |> List.hd,
                }),
              ],
            }),
            IdentifierExpression({name: fieldName}),
          ],
        });
      } else {
        FunctionCallExpression({
          expression: IdentifierExpression({name: "Json.Decode.field"}),
          arguments: [
            LiteralExpression({literal: String(entity.key)}),
            if (rendered.annotation.parameters == []) {
              IdentifierExpression({
                name: formatDecoderIdentifier(rendered.annotation.name),
              });
            } else {
              FunctionCallExpression({
                expression:
                  IdentifierExpression({
                    name: formatDecoderIdentifier(rendered.annotation.name),
                  }),
                arguments:
                  rendered.annotation.parameters
                  |> List.map((parameter: typeAnnotation) =>
                       formatDecoderIdentifier(parameter.name)
                     )
                  |> List.map(name => IdentifierExpression({name: name})),
              });
            },
            IdentifierExpression({name: fieldName}),
          ],
        });
      },
  };
};

type renderedTypeCase = {
  variantCase,
  types: list(typeDeclaration),
  decoder: switchCase,
};

let renderTypeCase =
    (
      options: conversionOptions,
      entity: TypeSystem.entity,
      typeCase: TypeSystem.typeCase,
    )
    : renderedTypeCase => {
  let entityTypeAnnotation = typeAnnotationForEntity(options, entity);
  switch (typeCase) {
  | NormalCase(name, parameters) =>
    let renderedParameters =
      parameters
      |> List.map((parameter: TypeSystem.normalTypeCaseParameter) =>
           renderTypeCaseParameterEntity(options, entity, parameter.value)
         );
    /* renderedParameters
       |> List.map((parameter: renderedTypeCaseParameter) =>
            Variable([parameter.decoder])
          ); */
    {
      variantCase: {
        name: formatCaseName(name),
        associatedData:
          renderedParameters
          |> List.map((parameter: renderedTypeCaseParameter) =>
               parameter.annotation
             ),
      },
      types: [],
      decoder: {
        pattern: LiteralExpression({literal: String(name)}),
        body:
          switch (renderedParameters) {
          | [] => [
              Expression(
                IdentifierExpression({name: formatCaseName(name)}),
              ),
            ]
          | [a] => [
              Variable([
                {
                  name: "decoded",
                  quantifiedAnnotation: None,
                  initializer_:
                    FunctionCallExpression({
                      expression: a.decoder,
                      arguments: [IdentifierExpression({name: "data"})],
                    }),
                },
              ]),
              Expression(
                FunctionCallExpression({
                  expression:
                    IdentifierExpression({name: formatCaseName(name)}),
                  arguments: [IdentifierExpression({name: "decoded"})],
                }),
              ),
            ]
          | _ =>
            let decoderName =
              "tuple" ++ string_of_int(List.length(renderedParameters));

            [
              Variable([
                {
                  name:
                    "("
                    ++ (
                      renderedParameters
                      |> List.mapi((i, _) => "var" ++ string_of_int(i))
                      |> Format.joinWith(", ")
                    )
                    ++ ")",
                  quantifiedAnnotation: None,
                  initializer_:
                    FunctionCallExpression({
                      expression:
                        FunctionCallExpression({
                          expression:
                            IdentifierExpression({
                              name: "Json.Decode." ++ decoderName,
                            }),
                          arguments:
                            renderedParameters
                            |> List.map(
                                 (parameter: renderedTypeCaseParameter) =>
                                 parameter.decoder
                               ),
                        }),
                      arguments: [IdentifierExpression({name: "data"})],
                    }),
                },
              ]),
              Expression(
                FunctionCallExpression({
                  expression:
                    IdentifierExpression({name: formatCaseName(name)}),
                  arguments:
                    renderedParameters
                    |> List.mapi((i, _) =>
                         IdentifierExpression({
                           name: "var" ++ string_of_int(i),
                         })
                       ),
                }),
              ),
            ];
          },
      },
    };
  | RecordCase(name, parameters) =>
    let renderedParameters =
      parameters
      |> List.map(renderRecordTypeCaseParameter(options, entity, "data"));
    let recordTypeName =
      formatRecordTypeName(name, entityTypeAnnotation.name);
    {
      variantCase: {
        name: formatCaseName(name),
        associatedData: [{name: recordTypeName, parameters: []}],
      },
      types: [
        {
          name: {
            name: recordTypeName,
            parameters: [],
          },
          value:
            RecordType({
              entries:
                renderedParameters
                |> List.map((parameter: renderedRecordTypeCaseParameter) =>
                     parameter.entry
                   ),
            }),
        },
      ],
      decoder: {
        pattern: LiteralExpression({literal: String(name)}),
        body: [
          Expression(
            FunctionCallExpression({
              expression: IdentifierExpression({name: formatCaseName(name)}),
              arguments: [
                LiteralExpression({
                  literal:
                    Record(
                      renderedParameters
                      |> List.map(
                           (parameter: renderedRecordTypeCaseParameter) =>
                           (
                             {
                               key: parameter.entry.key,
                               value: parameter.decoder,
                             }: recordEntry
                           )
                         ),
                    ),
                }),
              ],
            }),
          ),
        ],
      },
    };
  };
};

type renderedDeclarations = {
  types: list(typeDeclaration),
  decoders: list(variableDeclaration),
};

let renderEntity =
    (options: conversionOptions, entity: TypeSystem.entity)
    : renderedDeclarations => {
  let genericTypeNames = TypeSystem.Access.entityGenericParameters(entity);
  let entityTypeAnnotation = typeAnnotationForEntity(options, entity);

  switch (entity) {
  | GenericType(genericType) =>
    /* TODO: pass down entity instead of type annotation
       refactor, make function to get type annotation easily */
    let typeName = formatTypeName(genericType.name);
    let renderedCases: list(renderedTypeCase) =
      genericType.cases |> List.map(renderTypeCase(options, entity));
    let cases =
      renderedCases
      |> List.map((result: renderedTypeCase) => result.variantCase);
    let recordTypes =
      renderedCases |> List.map((result: renderedTypeCase) => result.types);
    let decoderCases =
      renderedCases |> List.map((result: renderedTypeCase) => result.decoder);

    let standardVariantType = [
      {name: entityTypeAnnotation, value: VariantType({cases: cases})},
    ];

    let types = recordTypes |> List.concat;

    let decoderAnnotation: quantifiedTypeAnnotation = {
      forall: genericTypeNames |> List.map(formatGenericName),
      annotation:
        functionTypeAnnotation(
          tupleNTypeAnnotation(
            (
              genericTypeNames
              |> List.map(name =>
                   {
                     name: "Json.Decode.decoder",
                     parameters: [
                       {name: formatGenericName(name), parameters: []},
                     ],
                   }
                 )
            )
            @ [{name: "Js.Json.t", parameters: []}],
          ),
          entityTypeAnnotation,
        ),
    };

    let decoderParameters: list(functionParameter) =
      (
        genericTypeNames
        |> List.map(name => {name: "decoder" ++ name, annotation: None})
      )
      @ [
        {
          name: "json",
          annotation: Some({name: "Js.Json.t", parameters: []}),
        },
      ];

    if (TypeSystem.Match.singleRecord(entity)) {
      switch (entity) {
      | GenericType({name: _, cases: [RecordCase(name, parameters)]}) =>
        let renderedParameters =
          parameters
          |> List.map(renderRecordTypeCaseParameter(options, entity, "json"));
        let recordTypeName =
          formatRecordTypeName(name, entityTypeAnnotation.name);

        let aliasType: typeDeclaration = {
          name: {
            name,
            parameters: [],
          },
          value: AliasType({name: recordTypeName, parameters: []}),
        };

        {
          types: types @ [aliasType],
          decoders: [
            {
              name: typeName,
              quantifiedAnnotation: Some(decoderAnnotation),
              initializer_:
                FunctionExpression({
                  parameters: decoderParameters,
                  returnType: None,
                  body: [
                    Expression(
                      LiteralExpression({
                        literal:
                          Record(
                            renderedParameters
                            |> List.map(
                                 (parameter: renderedRecordTypeCaseParameter) =>
                                 (
                                   {
                                     key: parameter.entry.key,
                                     value: parameter.decoder,
                                   }: recordEntry
                                 )
                               ),
                          ),
                      }),
                    ),
                  ],
                }),
            },
          ],
        };
      | _ => raise(Not_found)
      };
    } else if (TypeSystem.Match.linkedList(entity)) {
      let constantCase = List.hd(TypeSystem.Access.constantCases(entity));
      let recursiveCase =
        List.hd(TypeSystem.Access.entityRecursiveCases(entity));
      let constantCaseName = TypeSystem.Access.typeCaseName(constantCase);
      let recursiveCaseName = TypeSystem.Access.typeCaseName(recursiveCase);
      let recursiveType =
        List.hd(TypeSystem.Access.typeCaseParameterEntities(recursiveCase));
      {
        types: types @ standardVariantType,
        decoders: [
          {
            name: typeName,
            quantifiedAnnotation: Some(decoderAnnotation),
            initializer_:
              FunctionExpression({
                parameters: decoderParameters,
                returnType: None,
                body: [
                  Variable([
                    {
                      name: "decoded",
                      quantifiedAnnotation: None,
                      initializer_:
                        FunctionCallExpression({
                          expression:
                            IdentifierExpression({name: "Json.Decode.list"}),
                          arguments:
                            (
                              genericTypeNames
                              |> List.map(name =>
                                   IdentifierExpression({
                                     name: "decoder" ++ name,
                                   })
                                 )
                            )
                            @ [IdentifierExpression({name: "json"})],
                        }),
                    },
                  ]),
                  linkedListReducerFunction(
                    "createPairs",
                    IdentifierExpression({
                      name: formatCaseName(recursiveCaseName),
                    }),
                    IdentifierExpression({
                      name: formatCaseName(constantCaseName),
                    }),
                  ),
                  Expression(
                    FunctionCallExpression({
                      expression: IdentifierExpression({name: "createPairs"}),
                      arguments: [IdentifierExpression({name: "decoded"})],
                    }),
                  ),
                ],
              }),
          },
        ],
      };
    } else {
      {
        types: types @ standardVariantType,
        decoders: [
          {
            name: typeName,
            quantifiedAnnotation: Some(decoderAnnotation),
            initializer_:
              FunctionExpression({
                parameters: decoderParameters,
                returnType: None,
                body: [
                  Variable([
                    {
                      name: "case",
                      quantifiedAnnotation: None,
                      initializer_:
                        FunctionCallExpression({
                          expression:
                            IdentifierExpression({name: "Json.Decode.field"}),
                          arguments: [
                            LiteralExpression({literal: String("type")}),
                            IdentifierExpression({
                              name: "Json.Decode.string",
                            }),
                            IdentifierExpression({name: "json"}),
                          ],
                        }),
                    },
                  ]),
                  Variable([
                    {
                      name: "data",
                      quantifiedAnnotation: None,
                      initializer_:
                        FunctionCallExpression({
                          expression:
                            IdentifierExpression({name: "Json.Decode.field"}),
                          arguments: [
                            LiteralExpression({literal: String("data")}),
                            identityFunction,
                            IdentifierExpression({name: "json"}),
                          ],
                        }),
                    },
                  ]),
                  Expression(
                    SwitchExpression({
                      pattern: IdentifierExpression({name: "case"}),
                      cases:
                        decoderCases
                        @ [
                          {
                            pattern: IdentifierExpression({name: "_"}),
                            body: [
                              Expression(
                                FunctionCallExpression({
                                  expression:
                                    IdentifierExpression({name: "Js.log"}),
                                  arguments: [
                                    LiteralExpression({
                                      literal:
                                        String("Error decoding " ++ typeName),
                                    }),
                                  ],
                                }),
                              ),
                              Expression(
                                FunctionCallExpression({
                                  expression:
                                    IdentifierExpression({name: "raise"}),
                                  arguments: [
                                    IdentifierExpression({name: "Not_found"}),
                                  ],
                                }),
                              ),
                            ],
                          },
                        ],
                    }),
                  ),
                ],
              }),
          },
        ],
      };
    };
  | NativeType(value) => {types: [], decoders: []}
  };
};

let renderTypes = (file: TypeSystem.typesFile): list(ReasonAst.declaration) => {
  let nativeTypeNames =
    file.types
    |> List.map(TypeSystem.Access.nativeTypeName)
    |> Sequence.compact;

  let conversionOptions = {nativeTypeNames: nativeTypeNames};

  [
    Type(
      file.types
      |> List.map(renderEntity(conversionOptions))
      |> List.map(declarations => declarations.types)
      |> List.concat,
    ),
    Module({
      name: "Decode",
      declarations: [
        Variable(
          file.types
          |> List.map(renderEntity(conversionOptions))
          |> List.map(declarations => declarations.decoders)
          |> List.concat,
        ),
      ],
    }),
  ];
};

let renderToString = (file: TypeSystem.typesFile): string =>
  renderTypes(file)
  |> List.map(ReasonRender.renderDeclaration)
  |> List.map(ReasonRender.toString)
  |> Format.joinWith("\n\n");