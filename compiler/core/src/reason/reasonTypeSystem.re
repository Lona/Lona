open Operators;
open ReasonAst;

type conversionOptions = {
  discriminant: string,
  dataWrapper: string,
  nativeTypeNames: list(string),
};

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

let formatEncoderIdentifier = string =>
  switch (string) {
  | "bool" => "Json.Encode.bool"
  | "float" => "Json.Encode.float"
  | "string" => "Json.Encode.string"
  | "option" => "Json.Encode.nullable"
  | "list" when !definesCustomListType => "Json.Encode.list"
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
  encoder: expression,
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
        encoder:
          FunctionCallExpression({
            expression:
              IdentifierExpression({
                name: formatEncoderIdentifier(entityTypeAnnotation.name),
              }),
            arguments:
              genericTypeNames
              |> List.map(name => formatEncoderIdentifier(name))
              |> List.map(name =>
                   IdentifierExpression({name: "encoder" ++ name})
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
        encoder:
          if (replacedGenerics == []) {
            IdentifierExpression({name: formatEncoderIdentifier(typeName)});
          } else {
            FunctionCallExpression({
              expression:
                IdentifierExpression({
                  name: formatEncoderIdentifier(typeName),
                }),
              arguments:
                replacedGenerics
                |> List.map((annotation: typeAnnotation) => annotation.name)
                |> List.map(name =>
                     IdentifierExpression({
                       name: formatEncoderIdentifier(name),
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
      encoder: IdentifierExpression({name: "encoder" ++ name}),
    }
  };
};

type renderedRecordTypeCaseParameter = {
  entry: recordTypeEntry,
  decoder: expression,
  encoder: expression,
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
    encoder:
      if (isOptional) {
        FunctionCallExpression({
          expression:
            IdentifierExpression({
              name: formatEncoderIdentifier(rendered.annotation.name),
            }),
          arguments:
            (
              rendered.annotation.parameters
              |> List.map((parameter: typeAnnotation) =>
                   formatEncoderIdentifier(parameter.name)
                 )
              |> List.map(name => IdentifierExpression({name: name}))
            )
            @ [
              MemberExpression({
                expression: IdentifierExpression({name: "value"}),
                memberName: entity.key,
              }),
            ],
        });
      } else {
        FunctionCallExpression({
          expression:
            IdentifierExpression({
              name: formatEncoderIdentifier(rendered.annotation.name),
            }),
          arguments:
            (
              rendered.annotation.parameters
              |> List.map((parameter: typeAnnotation) =>
                   formatEncoderIdentifier(parameter.name)
                 )
              |> List.map(name => IdentifierExpression({name: name}))
            )
            @ [
              MemberExpression({
                expression: IdentifierExpression({name: "value"}),
                memberName: entity.key,
              }),
            ],
        });
      },
  };
};

type renderedTypeCase = {
  variantCase,
  types: list(typeDeclaration),
  decoder: switchCase,
  encoder: switchCase,
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
      encoder: {
        pattern:
          if (parameters == []) {
            IdentifierExpression({name: formatCaseName(name)});
          } else {
            FunctionCallExpression({
              expression: IdentifierExpression({name: formatCaseName(name)}),
              arguments:
                parameters
                |> List.mapi((index, _) =>
                     IdentifierExpression({
                       name: formatTypeName("value" ++ string_of_int(index)),
                     })
                   ),
            });
          },
        body:
          switch (renderedParameters) {
          | [] => [
              Expression(
                FunctionCallExpression({
                  expression:
                    IdentifierExpression({name: "Json.Encode.string"}),
                  arguments: [LiteralExpression({literal: String(name)})],
                }),
              ),
            ]
          | [a] => [
              Variable([
                {
                  name: "case",
                  quantifiedAnnotation: None,
                  initializer_:
                    FunctionCallExpression({
                      expression:
                        IdentifierExpression({name: "Json.Encode.string"}),
                      arguments: [
                        LiteralExpression({literal: String(name)}),
                      ],
                    }),
                },
              ]),
              Variable([
                {
                  name: "encoded",
                  quantifiedAnnotation: None,
                  initializer_:
                    FunctionCallExpression({
                      expression: a.encoder,
                      arguments: [IdentifierExpression({name: "value0"})],
                    }),
                },
              ]),
              Expression(
                FunctionCallExpression({
                  expression:
                    IdentifierExpression({name: "Json.Encode.object_"}),
                  arguments: [
                    LiteralExpression({
                      literal:
                        Array([
                          LiteralExpression({
                            literal:
                              Tuple([
                                LiteralExpression({
                                  literal: String(options.discriminant),
                                }),
                                IdentifierExpression({name: "case"}),
                              ]),
                          }),
                          LiteralExpression({
                            literal:
                              Tuple([
                                LiteralExpression({
                                  literal: String(options.dataWrapper),
                                }),
                                IdentifierExpression({name: "encoded"}),
                              ]),
                          }),
                        ]),
                    }),
                  ],
                }),
              ),
            ]
          | _ =>
            let encoderName =
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
                              name: "Json.Encode." ++ encoderName,
                            }),
                          arguments:
                            renderedParameters
                            |> List.map(
                                 (parameter: renderedTypeCaseParameter) =>
                                 parameter.encoder
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
      encoder: {
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
                               value: parameter.encoder,
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
  encoders: list(variableDeclaration),
};

let errorDecoding = (typeName: string): switchCase => {
  pattern: IdentifierExpression({name: "_"}),
  body: [
    Expression(
      FunctionCallExpression({
        expression: IdentifierExpression({name: "Js.log"}),
        arguments: [
          LiteralExpression({
            literal: String("Error decoding " ++ typeName),
          }),
        ],
      }),
    ),
    Expression(
      FunctionCallExpression({
        expression: IdentifierExpression({name: "raise"}),
        arguments: [IdentifierExpression({name: "Not_found"})],
      }),
    ),
  ],
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
    let encoderCases =
      renderedCases |> List.map((result: renderedTypeCase) => result.encoder);

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

    let encoderAnnotation: quantifiedTypeAnnotation = {
      forall: genericTypeNames |> List.map(formatGenericName),
      annotation:
        functionTypeAnnotation(
          tupleNTypeAnnotation(
            (
              genericTypeNames
              |> List.map(name =>
                   {
                     name: "Json.Encode.encoder",
                     parameters: [
                       {name: formatGenericName(name), parameters: []},
                     ],
                   }
                 )
            )
            @ [entityTypeAnnotation],
          ),
          {name: "Js.Json.t", parameters: []},
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

    let encoderParameters: list(functionParameter) =
      (
        genericTypeNames
        |> List.map(name => {name: "encoder" ++ name, annotation: None})
      )
      @ [{name: "value", annotation: Some(entityTypeAnnotation)}];

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
          encoders: [
            {
              name: typeName,
              quantifiedAnnotation: Some(encoderAnnotation),
              initializer_:
                FunctionExpression({
                  parameters: encoderParameters,
                  returnType: None,
                  body: [
                    Expression(
                      FunctionCallExpression({
                        expression:
                          IdentifierExpression({name: "Json.Encode.object_"}),
                        arguments: [
                          LiteralExpression({
                            literal:
                              Array(
                                renderedParameters
                                |> List.map(
                                     (
                                       parameter: renderedRecordTypeCaseParameter,
                                     ) =>
                                     LiteralExpression({
                                       literal:
                                         Tuple([
                                           LiteralExpression({
                                             literal:
                                               String(parameter.entry.key),
                                           }),
                                           parameter.encoder,
                                         ]),
                                     })
                                   ),
                              ),
                          }),
                        ],
                      }),
                    ),
                  ],
                }),
            },
          ],
        };
      | _ => raise(Not_found)
      };
    } else if (TypeSystem.Match.constant(entity)) {
      let typeCases = TypeSystem.Access.constantCases(entity);
      let variantCases =
        typeCases
        |> List.map(TypeSystem.Access.typeCaseName)
        |> List.map(name => {name: formatCaseName(name), associatedData: []});
      {
        types:
          types
          @ [
            {
              name: entityTypeAnnotation,
              value: VariantType({cases: variantCases}),
            },
          ],
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
                            IdentifierExpression({
                              name: "Json.Decode.string",
                            }),
                          arguments: [IdentifierExpression({name: "json"})],
                        }),
                    },
                  ]),
                  Expression(
                    SwitchExpression({
                      pattern: IdentifierExpression({name: "case"}),
                      cases: decoderCases @ [errorDecoding(typeName)],
                    }),
                  ),
                ],
              }),
          },
        ],
        encoders: [
          {
            name: typeName,
            quantifiedAnnotation: Some(encoderAnnotation),
            initializer_:
              FunctionExpression({
                parameters: encoderParameters,
                returnType: None,
                body: [
                  Expression(
                    SwitchExpression({
                      pattern: IdentifierExpression({name: "value"}),
                      cases: encoderCases,
                    }),
                  ),
                ],
              }),
          },
        ],
      };
    } else if (TypeSystem.Match.linkedList(entity)) {
      let constantCase = List.hd(TypeSystem.Access.constantCases(entity));
      let recursiveCase =
        List.hd(TypeSystem.Access.entityRecursiveCases(entity));
      let constantCaseName = TypeSystem.Access.typeCaseName(constantCase);
      let recursiveCaseName = TypeSystem.Access.typeCaseName(recursiveCase);
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
        encoders: [],
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
                            LiteralExpression({
                              literal: String(options.discriminant),
                            }),
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
                            LiteralExpression({
                              literal: String(options.dataWrapper),
                            }),
                            identityFunction,
                            IdentifierExpression({name: "json"}),
                          ],
                        }),
                    },
                  ]),
                  Expression(
                    SwitchExpression({
                      pattern: IdentifierExpression({name: "case"}),
                      cases: decoderCases @ [errorDecoding(typeName)],
                    }),
                  ),
                ],
              }),
          },
        ],
        encoders: [
          {
            name: typeName,
            quantifiedAnnotation: Some(encoderAnnotation),
            initializer_:
              FunctionExpression({
                parameters: encoderParameters,
                returnType: None,
                body: [
                  Expression(
                    SwitchExpression({
                      pattern: IdentifierExpression({name: "value"}),
                      cases: encoderCases,
                    }),
                  ),
                ],
              }),
          },
        ],
      };
    };
  | NativeType(_) => {types: [], decoders: [], encoders: []}
  };
};

let renderTypes =
    (options: Options.options, file: TypeSystem.typesFile)
    : list(ReasonAst.declaration) => {
  let nativeTypeNames =
    file.types
    |> List.map(TypeSystem.Access.nativeTypeName)
    |> Sequence.compact;

  let conversionOptions = {
    discriminant: options.discriminant,
    dataWrapper: options.dataWrapper,
    nativeTypeNames,
  };

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
    Module({
      name: "Encode",
      declarations: [
        Variable(
          file.types
          |> List.map(renderEntity(conversionOptions))
          |> List.map(declarations => declarations.encoders)
          |> List.concat,
        ),
      ],
    }),
  ];
};

let renderToString =
    (options: Options.options, file: TypeSystem.typesFile): string =>
  renderTypes(options, file)
  |> List.map(ReasonRender.renderDeclaration)
  |> List.map(ReasonRender.toString)
  |> Format.joinWith("\n\n");