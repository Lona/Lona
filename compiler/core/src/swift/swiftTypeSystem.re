type codingContainer =
  | Keyed
  | Unkeyed
  | SingleValue
  | NestedKeyed(string)
  | NestedUnkeyed;

type typeNameEncoding =
  | StringEncoding
  | IntegerEncoding
  | BooleanEncoding;

let encodedType = (encoding: typeNameEncoding, caseName: string, index: int) =>
  switch (encoding) {
  | StringEncoding => SwiftAst.String(caseName)
  | IntegerEncoding => Integer(index)
  | BooleanEncoding => Boolean(index == 0 ? false : true)
  };

type convertedEntity = {
  name: option(string),
  node: SwiftAst.node,
};

type conversionOptions = {
  discriminant: string,
  dataWrapper: string,
  nativeTypeNames: list(string),
  swiftOptions: SwiftOptions.options,
};

let isOptional =
    (typeCaseParameterEntity: TypeSystem.typeCaseParameterEntity): bool =>
  switch (typeCaseParameterEntity) {
  | TypeSystem.TypeReference(name, _) => name == "Optional"
  | GenericReference(_) => false
  };

module Naming = {
  let prefixedName = (conversionOptions: conversionOptions, name: string) =>
    List.mem(name, conversionOptions.nativeTypeNames) ?
      name : conversionOptions.swiftOptions.typePrefix ++ name;

  let recordName = (conversionOptions: conversionOptions, name: string) =>
    name |> Format.upperFirst |> prefixedName(conversionOptions);

  let prefixedType =
      (
        conversionOptions: conversionOptions,
        useTypePrefix: bool,
        typeCaseParameterEntity: TypeSystem.typeCaseParameterEntity,
      )
      : string => {
    let formattedName = name =>
      useTypePrefix ? prefixedName(conversionOptions, name) : name;
    switch (typeCaseParameterEntity) {
    | TypeSystem.TypeReference(name, []) => formattedName(name)
    | TypeSystem.TypeReference(name, parameters) =>
      let generics =
        parameters
        |> List.map((parameter: TypeSystem.genericTypeParameterSubstitution) =>
             formattedName(parameter.instance)
           )
        |> Format.joinWith(", ");
      formattedName(name) ++ "<" ++ generics ++ ">";
    | GenericReference(name) => name
    };
  };

  let innerType =
      (
        conversionOptions: conversionOptions,
        useTypePrefix: bool,
        typeCaseParameterEntity: TypeSystem.typeCaseParameterEntity,
      )
      : option(string) => {
    let formattedName = name =>
      useTypePrefix ? prefixedName(conversionOptions, name) : name;
    switch (typeCaseParameterEntity) {
    | TypeSystem.TypeReference(_, [parameter]) =>
      Some(formattedName(parameter.instance))
    | TypeSystem.TypeReference(_) => None
    | GenericReference(_) => None
    };
  };

  let typeName =
      (
        conversionOptions: conversionOptions,
        useTypePrefix: bool,
        typeCaseParameterEntity: TypeSystem.typeCaseParameterEntity,
      )
      : SwiftAst.typeAnnotation =>
    TypeName(
      prefixedType(conversionOptions, useTypePrefix, typeCaseParameterEntity),
    );

  let codingContainer = (container: codingContainer): string =>
    switch (container) {
    | Keyed => "container"
    | Unkeyed => "unkeyedContainer"
    | SingleValue => "singleValueContainer"
    | NestedKeyed(_) => "nestedContainer"
    | NestedUnkeyed => "nestedUnkeyedContainer"
    };
};

module Ast = {
  open SwiftAst;

  module Decoding = {
    /* Produces:
     * public init(from decoder: Decoder) throws {}
     */
    let decodableInitializer = (body: list(SwiftAst.node)) =>
      InitializerDeclaration({
        "modifiers": [AccessLevelModifier(PublicModifier)],
        "parameters": [
          Parameter({
            "externalName": Some("from"),
            "localName": "decoder",
            "annotation": TypeName("Decoder"),
            "defaultValue": None,
          }),
        ],
        "failable": None,
        "throws": true,
        "body": body,
      });

    let decodingContainer =
        (
          decoderName: string,
          variableName: string,
          container: codingContainer,
          codingKeysName: string,
        ) => {
      let pattern =
        IdentifierPattern({
          "identifier": SwiftIdentifier(variableName),
          "annotation": None,
        });
      let init =
        Some(
          TryExpression({
            "expression":
              FunctionCallExpression({
                "name":
                  MemberExpression([
                    SwiftIdentifier(decoderName),
                    SwiftIdentifier(container |> Naming.codingContainer),
                  ]),
                "arguments":
                  switch (container) {
                  | Keyed => [
                      FunctionCallArgument({
                        "name": Some(SwiftIdentifier("keyedBy")),
                        "value":
                          MemberExpression([
                            SwiftIdentifier(codingKeysName),
                            SwiftIdentifier("self"),
                          ]),
                      }),
                    ]
                  | NestedKeyed(nestedKey) => [
                      FunctionCallArgument({
                        "name": Some(SwiftIdentifier("keyedBy")),
                        "value":
                          MemberExpression([
                            SwiftIdentifier(codingKeysName),
                            SwiftIdentifier("self"),
                          ]),
                      }),
                      FunctionCallArgument({
                        "name": Some(SwiftIdentifier("forKey")),
                        "value":
                          MemberExpression([
                            SwiftIdentifier("CodingKeys"),
                            SwiftIdentifier(nestedKey),
                          ]),
                      }),
                    ]
                  | _ => []
                  },
              }),
            "forced": false,
            "optional": false,
          }),
        );
      switch (container) {
      | Unkeyed
      | NestedUnkeyed =>
        VariableDeclaration({
          "modifiers": [],
          "pattern": pattern,
          "init": init,
          "block": None,
        })
      | _ =>
        ConstantDeclaration({
          "modifiers": [],
          "pattern": pattern,
          "init": init,
        })
      };
    };

    let nestedUnkeyedDecodingContainer =
        (containerName: string, codingKey: string) =>
      VariableDeclaration({
        "modifiers": [],
        "pattern":
          IdentifierPattern({
            "identifier": SwiftIdentifier("unkeyedContainer"),
            "annotation": None,
          }),
        "init":
          Some(
            TryExpression({
              "expression":
                FunctionCallExpression({
                  "name":
                    MemberExpression([
                      SwiftIdentifier(containerName),
                      SwiftIdentifier("nestedUnkeyedContainer"),
                    ]),
                  "arguments": [
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("forKey")),
                      "value": SwiftIdentifier("." ++ codingKey),
                    }),
                  ],
                }),
              "forced": false,
              "optional": false,
            }),
          ),
        "block": None,
      });

    let containerDecode =
        (
          containerName: string,
          value: node,
          codingKey: option(string),
          isOptional: bool,
        ) =>
      TryExpression({
        "expression":
          FunctionCallExpression({
            "name":
              MemberExpression([
                SwiftIdentifier(containerName),
                SwiftIdentifier(isOptional ? "decodeIfPresent" : "decode"),
              ]),
            "arguments":
              [FunctionCallArgument({"name": None, "value": value})]
              @ (
                switch (codingKey) {
                | Some(key) => [
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("forKey")),
                      "value": SwiftIdentifier("." ++ key),
                    }),
                  ]
                | None => []
                }
              ),
          }),
        "forced": false,
        "optional": false,
      });

    let unkeyedContainerDecode = (value: node) =>
      TryExpression({
        "expression":
          FunctionCallExpression({
            "name":
              MemberExpression([
                SwiftIdentifier("unkeyedContainer"),
                SwiftIdentifier("decode"),
              ]),
            "arguments": [
              FunctionCallArgument({"name": None, "value": value}),
            ],
          }),
        "forced": false,
        "optional": false,
      });

    let enumCaseDataDecoding =
        (conversionOptions: conversionOptions, typeCase: TypeSystem.typeCase)
        : list(SwiftAst.node) =>
      switch (typeCase) {
      /* Multiple parameters are encoded as an array */
      | NormalCase(name, [_, _, ..._] as parameters) =>
        let decodeParameters =
          parameters
          |> List.map((parameter: TypeSystem.normalTypeCaseParameter) =>
               FunctionCallArgument({
                 "name": None,
                 "value":
                   unkeyedContainerDecode(
                     MemberExpression([
                       SwiftIdentifier(
                         parameter.value
                         |> Naming.prefixedType(conversionOptions, true),
                       ),
                       SwiftIdentifier("self"),
                     ]),
                   ),
               })
             );
        [
          nestedUnkeyedDecodingContainer(
            "container",
            conversionOptions.dataWrapper,
          ),
        ]
        @ [
          BinaryExpression({
            "left": SwiftIdentifier("self"),
            "operator": "=",
            "right":
              FunctionCallExpression({
                "name":
                  SwiftIdentifier(
                    "." ++ SwiftFormat.stringWithSafeIdentifier(name),
                  ),
                "arguments": decodeParameters,
              }),
          }),
        ];
      /* self = .value(try container.decode(Value.self, forKey: .data)) */
      | NormalCase(name, [parameter]) =>
        let optionalType: option(string) =
          if (isOptional(parameter.value)) {
            Naming.innerType(conversionOptions, true, parameter.value);
          } else {
            None;
          };
        [
          BinaryExpression({
            "left": SwiftIdentifier("self"),
            "operator": "=",
            "right":
              FunctionCallExpression({
                "name": SwiftIdentifier("." ++ name),
                "arguments": [
                  FunctionCallArgument({
                    "name": None,
                    "value":
                      containerDecode(
                        "container",
                        MemberExpression([
                          SwiftIdentifier(
                            switch (optionalType) {
                            | Some(typeName) => typeName
                            | None =>
                              parameter.value
                              |> Naming.prefixedType(conversionOptions, true)
                            },
                          ),
                          SwiftIdentifier("self"),
                        ]),
                        Some(conversionOptions.dataWrapper),
                        optionalType != None,
                      ),
                  }),
                ],
              }),
          }),
        ];
      | NormalCase(name, [])
      | RecordCase(name, []) => [
          BinaryExpression({
            "left": SwiftIdentifier("self"),
            "operator": "=",
            "right":
              SwiftIdentifier(
                "." ++ SwiftFormat.stringWithSafeIdentifier(name),
              ),
          }),
        ]
      | RecordCase(name, parameters) => [
          BinaryExpression({
            "left": SwiftIdentifier("self"),
            "operator": "=",
            "right":
              FunctionCallExpression({
                "name": SwiftIdentifier("." ++ name),
                "arguments":
                  parameters
                  |> List.map((parameter: TypeSystem.recordTypeCaseParameter) => {
                       let optionalType =
                         if (isOptional(parameter.value)) {
                           Naming.innerType(
                             conversionOptions,
                             true,
                             parameter.value,
                           );
                         } else {
                           None;
                         };
                       FunctionCallArgument({
                         "name": Some(SwiftIdentifier(parameter.key)),
                         "value":
                           containerDecode(
                             conversionOptions.dataWrapper,
                             MemberExpression([
                               SwiftIdentifier(
                                 switch (optionalType) {
                                 | Some(typeName) => typeName
                                 | None =>
                                   parameter.value
                                   |> TypeSystem.Access.typeCaseParameterEntityName
                                   |> Naming.recordName(conversionOptions)
                                 },
                               ),
                               SwiftIdentifier("self"),
                             ]),
                             Some(parameter.key),
                             optionalType != None,
                           ),
                       });
                     }),
              }),
          }),
        ]
      };

    let enumCaseDecoding =
        (conversionOptions: conversionOptions, typeCase: TypeSystem.typeCase)
        : SwiftAst.node => {
      let caseName = typeCase |> TypeSystem.Access.typeCaseName;

      CaseLabel({
        "patterns": [
          ExpressionPattern({"value": LiteralExpression(String(caseName))}),
        ],
        "statements": enumCaseDataDecoding(conversionOptions, typeCase),
      });
    };

    let enumDecoding =
        (
          conversionOptions: conversionOptions,
          typeCases: list(TypeSystem.typeCase),
        )
        : list(SwiftAst.node) => {
      let recordCaseLabels = TypeSystem.Access.allRecordCaseLabels(typeCases);

      [decodingContainer("decoder", "container", Keyed, "CodingKeys")]
      @ (
        recordCaseLabels != [] ?
          [
            decodingContainer(
              "container",
              conversionOptions.dataWrapper,
              NestedKeyed(conversionOptions.dataWrapper),
              "DataCodingKeys",
            ),
          ] :
          []
      )
      @ [
        ConstantDeclaration({
          "modifiers": [],
          "pattern":
            IdentifierPattern({
              "identifier": SwiftIdentifier(conversionOptions.discriminant),
              "annotation": None,
            }),
          "init":
            Some(
              containerDecode(
                "container",
                MemberExpression([
                  SwiftIdentifier("String"),
                  SwiftIdentifier("self"),
                ]),
                Some(conversionOptions.discriminant),
                false,
              ),
            ),
        }),
        Empty,
        SwitchStatement({
          "expression": SwiftIdentifier(conversionOptions.discriminant),
          "cases":
            (typeCases |> List.map(enumCaseDecoding(conversionOptions)))
            @ [
              DefaultCaseLabel({
                "statements": [
                  FunctionCallExpression({
                    "name": SwiftIdentifier("fatalError"),
                    "arguments": [
                      FunctionCallArgument({
                        "name": None,
                        "value":
                          SwiftIdentifier(
                            "\"Failed to decode enum due to invalid case type.\"",
                          ),
                      }),
                    ],
                  }),
                ],
              }),
            ],
        }),
      ];
    };

    let linkedListDecoding =
        (
          conversionOptions: conversionOptions,
          typeCases: list(TypeSystem.typeCase),
          recursiveCaseName: string,
          recursiveTypeName: string,
          constantCaseName: string,
        )
        : list(SwiftAst.node) => [
      decodingContainer("decoder", "unkeyedContainer", Unkeyed, "CodingKeys"),
      Empty,
      VariableDeclaration({
        "modifiers": [],
        "pattern":
          IdentifierPattern({
            "identifier": SwiftIdentifier("items"),
            "annotation": Some(ArrayType(TypeName("T"))),
          }),
        "init": Some(LiteralExpression(Array([]))),
        "block": None,
      }),
      WhileStatement({
        "condition":
          MemberExpression([
            SwiftIdentifier("!unkeyedContainer"),
            SwiftIdentifier("isAtEnd"),
          ]),
        "block": [
          FunctionCallExpression({
            "name":
              MemberExpression([
                SwiftIdentifier("items"),
                SwiftIdentifier("append"),
              ]),
            "arguments": [
              FunctionCallArgument({
                "name": None,
                "value":
                  unkeyedContainerDecode(
                    MemberExpression([
                      SwiftIdentifier(recursiveTypeName),
                      SwiftIdentifier("self"),
                    ]),
                  ),
              }),
            ],
          }),
        ],
      }),
      Empty,
      BinaryExpression({
        "left": SwiftIdentifier("self"),
        "operator": "=",
        "right": SwiftIdentifier("." ++ constantCaseName),
      }),
      WhileStatement({
        "condition":
          OptionalBindingCondition({
            "const": true,
            "pattern":
              IdentifierPattern({
                "identifier": SwiftIdentifier("item"),
                "annotation": None,
              }),
            "init":
              FunctionCallExpression({
                "name":
                  MemberExpression([
                    SwiftIdentifier("items"),
                    SwiftIdentifier("popLast"),
                  ]),
                "arguments": [],
              }),
          }),
        "block": [
          BinaryExpression({
            "left": SwiftIdentifier("self"),
            "operator": "=",
            "right":
              FunctionCallExpression({
                "name": SwiftIdentifier("." ++ recursiveCaseName),
                "arguments": [
                  FunctionCallArgument({
                    "name": None,
                    "value": SwiftIdentifier("item"),
                  }),
                  FunctionCallArgument({
                    "name": None,
                    "value": SwiftIdentifier("self"),
                  }),
                ],
              }),
          }),
        ],
      }),
    ];

    let nullaryDecoding =
        (conversionOptions: conversionOptions, constantCaseName: string)
        : list(SwiftAst.node) => [
      BinaryExpression({
        "left": SwiftIdentifier("self"),
        "operator": "=",
        "right": SwiftIdentifier("." ++ constantCaseName),
      }),
    ];

    let constantCaseDecoding =
        (
          conversionOptions: conversionOptions,
          encoding: typeNameEncoding,
          index: int,
          typeCase: TypeSystem.typeCase,
        )
        : SwiftAst.node => {
      let caseName = typeCase |> TypeSystem.Access.typeCaseName;

      CaseLabel({
        "patterns": [
          ExpressionPattern({
            "value":
              LiteralExpression(encodedType(encoding, caseName, index)),
          }),
        ],
        "statements": enumCaseDataDecoding(conversionOptions, typeCase),
      });
    };

    let constantDecoding =
        (
          conversionOptions: conversionOptions,
          encoding: typeNameEncoding,
          typeCases: list(TypeSystem.typeCase),
        )
        : list(SwiftAst.node) => [
      decodingContainer("decoder", "container", SingleValue, "CodingKeys"),
      ConstantDeclaration({
        "modifiers": [],
        "pattern":
          IdentifierPattern({
            "identifier": SwiftIdentifier(conversionOptions.discriminant),
            "annotation": None,
          }),
        "init":
          Some(
            containerDecode(
              "container",
              MemberExpression([
                SwiftIdentifier(
                  switch (encoding) {
                  | StringEncoding => "String"
                  | IntegerEncoding => "Int"
                  | BooleanEncoding => "Bool"
                  },
                ),
                SwiftIdentifier("self"),
              ]),
              None,
              false,
            ),
          ),
      }),
      Empty,
      SwitchStatement({
        "expression": SwiftIdentifier(conversionOptions.discriminant),
        "cases":
          (
            typeCases
            |> List.mapi((index, case) =>
                 constantCaseDecoding(
                   conversionOptions,
                   encoding,
                   index,
                   case,
                 )
               )
          )
          @ (
            switch (encoding) {
            | BooleanEncoding => []
            | IntegerEncoding
            | StringEncoding => [
                DefaultCaseLabel({
                  "statements": [
                    FunctionCallExpression({
                      "name": SwiftIdentifier("fatalError"),
                      "arguments": [
                        FunctionCallArgument({
                          "name": None,
                          "value":
                            SwiftIdentifier(
                              "\"Failed to decode enum due to invalid case type.\"",
                            ),
                        }),
                      ],
                    }),
                  ],
                }),
              ]
            }
          ),
      }),
    ];
  };

  module Encoding = {
    /* Produces:
     * public func encode(to encoder: Encoder) throws {}
     */
    let encodableFunction = (body: list(SwiftAst.node)) =>
      FunctionDeclaration({
        "name": "encode",
        "attributes": [],
        "modifiers": [AccessLevelModifier(PublicModifier)],
        "parameters": [
          Parameter({
            "externalName": Some("to"),
            "localName": "encoder",
            "annotation": TypeName("Encoder"),
            "defaultValue": None,
          }),
        ],
        "throws": true,
        "result": None,
        "body": body,
      });

    let encodingContainer =
        (
          encoderName: string,
          variableName: string,
          container: codingContainer,
          codingKeysName: string,
        ) =>
      VariableDeclaration({
        "modifiers": [],
        "pattern":
          IdentifierPattern({
            "identifier": SwiftIdentifier(variableName),
            "annotation": None,
          }),
        "init":
          Some(
            FunctionCallExpression({
              "name":
                MemberExpression([
                  SwiftIdentifier(encoderName),
                  SwiftIdentifier(container |> Naming.codingContainer),
                ]),
              "arguments":
                switch (container) {
                | Keyed => [
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("keyedBy")),
                      "value":
                        MemberExpression([
                          SwiftIdentifier(codingKeysName),
                          SwiftIdentifier("self"),
                        ]),
                    }),
                  ]
                | NestedKeyed(nestedKey) => [
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("keyedBy")),
                      "value":
                        MemberExpression([
                          SwiftIdentifier(codingKeysName),
                          SwiftIdentifier("self"),
                        ]),
                    }),
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("forKey")),
                      "value":
                        MemberExpression([
                          SwiftIdentifier("CodingKeys"),
                          SwiftIdentifier(nestedKey),
                        ]),
                    }),
                  ]
                | _ => []
                },
            }),
          ),
        "block": None,
      });

    let nestedUnkeyedEncodingContainer =
        (containerName: string, codingKey: string) =>
      VariableDeclaration({
        "modifiers": [],
        "pattern":
          IdentifierPattern({
            "identifier": SwiftIdentifier("unkeyedContainer"),
            "annotation": None,
          }),
        "init":
          Some(
            FunctionCallExpression({
              "name":
                MemberExpression([
                  SwiftIdentifier(containerName),
                  SwiftIdentifier("nestedUnkeyedContainer"),
                ]),
              "arguments": [
                FunctionCallArgument({
                  "name": Some(SwiftIdentifier("forKey")),
                  "value": SwiftIdentifier("." ++ codingKey),
                }),
              ],
            }),
          ),
        "block": None,
      });

    let containerEncode =
        (
          containerName: string,
          value: node,
          codingKey: option(string),
          isOptional: bool,
        ) =>
      TryExpression({
        "expression":
          FunctionCallExpression({
            "name":
              MemberExpression([
                SwiftIdentifier(containerName),
                SwiftIdentifier(isOptional ? "encodeIfPresent" : "encode"),
              ]),
            "arguments":
              [FunctionCallArgument({"name": None, "value": value})]
              @ (
                switch (codingKey) {
                | Some(key) => [
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("forKey")),
                      "value": SwiftIdentifier("." ++ key),
                    }),
                  ]
                | None => []
                }
              ),
          }),
        "forced": false,
        "optional": false,
      });

    let unkeyedContainerEncode = (value: node) =>
      TryExpression({
        "expression":
          FunctionCallExpression({
            "name":
              MemberExpression([
                SwiftIdentifier("unkeyedContainer"),
                SwiftIdentifier("encode"),
              ]),
            "arguments": [
              FunctionCallArgument({"name": None, "value": value}),
            ],
          }),
        "forced": false,
        "optional": false,
      });

    let enumCaseDataEncoding =
        (conversionOptions: conversionOptions, typeCase: TypeSystem.typeCase)
        : list(SwiftAst.node) =>
      switch (typeCase) {
      /* Multiple parameters are encoded as an array */
      | NormalCase(_, [_, _, ..._] as parameters) =>
        let encodeParameters =
          parameters
          |> List.mapi((i, _parameter) =>
               unkeyedContainerEncode(
                 MemberExpression([
                   SwiftIdentifier("value"),
                   SwiftIdentifier(string_of_int(i)),
                 ]),
               )
             );
        [
          nestedUnkeyedEncodingContainer(
            "container",
            conversionOptions.dataWrapper,
          ),
        ]
        @ encodeParameters;
      /* A single parameter is encoded automatically */
      | NormalCase(_, [parameter]) => [
          containerEncode(
            "container",
            SwiftIdentifier("value"),
            Some(conversionOptions.dataWrapper),
            isOptional(parameter.value),
          ),
        ]
      | NormalCase(_, [])
      | RecordCase(_, []) => []
      | RecordCase(_, [parameter]) => [
          containerEncode(
            conversionOptions.dataWrapper,
            MemberExpression([SwiftIdentifier("value")]),
            Some(parameter.key),
            isOptional(parameter.value),
          ),
        ]
      | RecordCase(_, parameters) =>
        parameters
        |> List.map((parameter: TypeSystem.recordTypeCaseParameter) =>
             containerEncode(
               conversionOptions.dataWrapper,
               MemberExpression([
                 SwiftIdentifier("value"),
                 SwiftIdentifier(parameter.key),
               ]),
               Some(parameter.key),
               isOptional(parameter.value),
             )
           )
      };

    /* case .undefined:
         try container.encode("undefined", forKey: .type)
       */
    let enumCaseEncoding =
        (conversionOptions: conversionOptions, typeCase: TypeSystem.typeCase)
        : SwiftAst.node => {
      let caseName = typeCase |> TypeSystem.Access.typeCaseName;

      let parameters =
        TypeSystem.Access.typeCaseParameterCount(typeCase) > 0 ?
          Some(
            TuplePattern([
              ValueBindingPattern({
                "kind": "let",
                "pattern":
                  IdentifierPattern({
                    "identifier": SwiftIdentifier("value"),
                    "annotation": None,
                  }),
              }),
            ]),
          ) :
          None;

      CaseLabel({
        "patterns": [
          EnumCasePattern({
            "typeIdentifier": None,
            "caseName": caseName,
            "tuplePattern": parameters,
          }),
        ],
        "statements":
          [
            containerEncode(
              "container",
              LiteralExpression(String(caseName)),
              Some(conversionOptions.discriminant),
              false,
            ),
          ]
          @ enumCaseDataEncoding(conversionOptions, typeCase),
      });
    };

    /* var container = encoder.container(keyedBy: CodingKeys.self)
       switch self {
       ...
       }
       */
    let enumEncoding =
        (
          conversionOptions: conversionOptions,
          typeCases: list(TypeSystem.typeCase),
        )
        : list(SwiftAst.node) => {
      let recordCaseLabels = TypeSystem.Access.allRecordCaseLabels(typeCases);

      [encodingContainer("encoder", "container", Keyed, "CodingKeys")]
      @ (
        recordCaseLabels != [] ?
          [
            encodingContainer(
              "container",
              conversionOptions.dataWrapper,
              NestedKeyed(conversionOptions.dataWrapper),
              "DataCodingKeys",
            ),
          ] :
          []
      )
      @ [
        Empty,
        SwitchStatement({
          "expression": SwiftIdentifier("self"),
          "cases":
            typeCases |> List.map(enumCaseEncoding(conversionOptions)),
        }),
      ];
    };
    /* public func encode(to encoder: Encoder) throws {
         var unkeyedContainer = encoder.unkeyedContainer()

         var head = self

         while case let .node(item, next) = head {
           try unkeyedContainer.encode(item)
           head = next
         }
       }
       */
    let linkedListEncoding =
        (typeCases: list(TypeSystem.typeCase), recursiveCaseName: string)
        : list(SwiftAst.node) => [
      encodingContainer("encoder", "unkeyedContainer", Unkeyed, "CodingKeys"),
      Empty,
      VariableDeclaration({
        "modifiers": [],
        "pattern":
          IdentifierPattern({
            "identifier": SwiftIdentifier("head"),
            "annotation": None,
          }),
        "init": Some(SwiftIdentifier("self")),
        "block": None,
      }),
      Empty,
      WhileStatement({
        "condition":
          CaseCondition({
            "pattern":
              ValueBindingPattern({
                "kind": "let",
                "pattern":
                  EnumCasePattern({
                    "typeIdentifier": None,
                    "caseName": recursiveCaseName,
                    "tuplePattern":
                      Some(
                        TuplePattern([
                          IdentifierPattern({
                            "identifier": SwiftIdentifier("item"),
                            "annotation": None,
                          }),
                          IdentifierPattern({
                            "identifier": SwiftIdentifier("next"),
                            "annotation": None,
                          }),
                        ]),
                      ),
                  }),
              }),
            "init": SwiftIdentifier("head"),
          }),
        "block": [
          unkeyedContainerEncode(SwiftIdentifier("item")),
          BinaryExpression({
            "left": SwiftIdentifier("head"),
            "operator": "=",
            "right": SwiftIdentifier("next"),
          }),
        ],
      }),
    ];

    let constantCaseEncoding =
        (
          conversionOptions: conversionOptions,
          encoding: typeNameEncoding,
          index: int,
          typeCase: TypeSystem.typeCase,
        )
        : SwiftAst.node => {
      let caseName = typeCase |> TypeSystem.Access.typeCaseName;

      let parameters =
        TypeSystem.Access.typeCaseParameterCount(typeCase) > 0 ?
          Some(
            TuplePattern([
              ValueBindingPattern({
                "kind": "let",
                "pattern":
                  IdentifierPattern({
                    "identifier": SwiftIdentifier("value"),
                    "annotation": None,
                  }),
              }),
            ]),
          ) :
          None;

      CaseLabel({
        "patterns": [
          EnumCasePattern({
            "typeIdentifier": None,
            "caseName": caseName,
            "tuplePattern": parameters,
          }),
        ],
        "statements":
          [
            containerEncode(
              "container",
              LiteralExpression(encodedType(encoding, caseName, index)),
              None,
              false,
            ),
          ]
          @ enumCaseDataEncoding(conversionOptions, typeCase),
      });
    };

    let constantEncoding =
        (
          conversionOptions: conversionOptions,
          encoding: typeNameEncoding,
          typeCases: list(TypeSystem.typeCase),
        )
        : list(SwiftAst.node) => [
      encodingContainer("encoder", "container", SingleValue, "CodingKeys"),
      Empty,
      SwitchStatement({
        "expression": SwiftIdentifier("self"),
        "cases":
          typeCases
          |> List.mapi((index, case) =>
               constantCaseEncoding(conversionOptions, encoding, index, case)
             ),
      }),
    ];
  };

  let codingKeys = (enumName: string, names: list(string)) =>
    EnumDeclaration({
      "name": enumName,
      "isIndirect": false,
      "inherits": [TypeName("CodingKey")],
      "modifier": Some(PublicModifier),
      "body":
        names
        |> List.map(name =>
             EnumCase({
               "name": SwiftIdentifier(name),
               "parameters": None,
               "value": None,
             })
           ),
    });
};

module Build = {
  open SwiftAst;

  let record =
      (
        conversionOptions: conversionOptions,
        name: string,
        parameters: list(TypeSystem.recordTypeCaseParameter),
      )
      : SwiftAst.node =>
    StructDeclaration({
      "name":
        name |> Format.upperFirst |> Naming.prefixedName(conversionOptions),
      "inherits": [
        ProtocolCompositionType([
          TypeName("Codable"),
          TypeName("Equatable"),
        ]),
      ],
      "modifier": Some(PublicModifier),
      "body":
        SwiftDocument.joinGroups(
          Empty,
          [
            [
              InitializerDeclaration({
                "modifiers": [AccessLevelModifier(PublicModifier)],
                "parameters":
                  parameters
                  |> List.map((parameter: TypeSystem.recordTypeCaseParameter) =>
                       Parameter({
                         "externalName": None,
                         "localName": parameter.key,
                         "annotation":
                           parameter.value
                           |> Naming.typeName(conversionOptions, true),
                         "defaultValue": None,
                       })
                     ),
                "failable": None,
                "throws": false,
                "body":
                  parameters
                  |> List.map((parameter: TypeSystem.recordTypeCaseParameter) =>
                       BinaryExpression({
                         "left":
                           SwiftAst.Builders.memberExpression([
                             "self",
                             parameter.key,
                           ]),
                         "operator": "=",
                         "right": SwiftIdentifier(parameter.key),
                       })
                     ),
              }),
            ],
            parameters
            |> List.map((parameter: TypeSystem.recordTypeCaseParameter) =>
                 VariableDeclaration({
                   "modifiers": [AccessLevelModifier(PublicModifier)],
                   "pattern":
                     IdentifierPattern({
                       "identifier": SwiftIdentifier(parameter.key),
                       "annotation":
                         Some(
                           parameter.value
                           |> Naming.typeName(conversionOptions, true),
                         ),
                     }),
                   "init": None,
                   "block": None,
                 })
               ),
          ],
        ),
    });

  let enumCase =
      (conversionOptions: conversionOptions, typeCase: TypeSystem.typeCase)
      : SwiftAst.node => {
    let name = typeCase |> TypeSystem.Access.typeCaseName;
    let parameterCount =
      switch (typeCase) {
      | RecordCase(_, _) => 1
      | NormalCase(_, parameters) => List.length(parameters)
      };

    let tupleElements: list(tupleTypeElement) =
      switch (typeCase) {
      | RecordCase(_, parameters) =>
        parameters
        |> List.map((parameter: TypeSystem.recordTypeCaseParameter) =>
             {
               elementName: Some(parameter.key),
               annotation:
                 parameter.value |> Naming.typeName(conversionOptions, true),
             }
           )
      | NormalCase(_, parameters) =>
        parameters
        |> List.map((parameter: TypeSystem.normalTypeCaseParameter) =>
             {
               elementName: None,
               annotation:
                 parameter.value |> Naming.typeName(conversionOptions, true),
             }
           )
      };
    EnumCase({
      "name": SwiftIdentifier(name),
      "parameters":
        parameterCount > 0 ? Some(TupleType(tupleElements)) : None,
      "value": None,
    });
  };

  let enumCodable =
      (
        conversionOptions: conversionOptions,
        cases: list(TypeSystem.typeCase),
      )
      : list(SwiftAst.node) => {
    let recordCaseLabels = TypeSystem.Access.allRecordCaseLabels(cases);

    SwiftDocument.join(
      Empty,
      [
        LineComment("MARK: Codable"),
        Ast.codingKeys(
          "CodingKeys",
          [conversionOptions.discriminant, conversionOptions.dataWrapper],
        ),
      ]
      @ (
        recordCaseLabels != [] ?
          [Ast.codingKeys("DataCodingKeys", recordCaseLabels)] : []
      )
      @ [
        Ast.Decoding.decodableInitializer(
          Ast.Decoding.enumDecoding(conversionOptions, cases),
        ),
        Ast.Encoding.encodableFunction(
          Ast.Encoding.enumEncoding(conversionOptions, cases),
        ),
      ],
    );
  };

  let linkedListCodable =
      (
        conversionOptions: conversionOptions,
        cases: list(TypeSystem.typeCase),
        recursiveCaseName: string,
        recursiveTypeName: string,
        constantCaseName: string,
      )
      : list(SwiftAst.node) =>
    SwiftDocument.join(
      Empty,
      [
        LineComment("MARK: Codable"),
        Ast.Decoding.decodableInitializer(
          Ast.Decoding.linkedListDecoding(
            conversionOptions,
            cases,
            recursiveCaseName,
            recursiveTypeName,
            constantCaseName,
          ),
        ),
        Ast.Encoding.encodableFunction(
          Ast.Encoding.linkedListEncoding(cases, recursiveCaseName),
        ),
      ],
    );

  let nullaryCodable =
      (conversionOptions: conversionOptions, constantCaseName: string)
      : list(SwiftAst.node) =>
    SwiftDocument.join(
      Empty,
      [
        LineComment("MARK: Codable"),
        Ast.Decoding.decodableInitializer(
          Ast.Decoding.nullaryDecoding(conversionOptions, constantCaseName),
        ),
        Ast.Encoding.encodableFunction([]),
      ],
    );

  let constantCodable =
      (
        conversionOptions: conversionOptions,
        encoding: typeNameEncoding,
        cases: list(TypeSystem.typeCase),
      )
      : list(SwiftAst.node) =>
    SwiftDocument.join(
      Empty,
      [
        LineComment("MARK: Codable"),
        Ast.Decoding.decodableInitializer(
          Ast.Decoding.constantDecoding(conversionOptions, encoding, cases),
        ),
        Ast.Encoding.encodableFunction(
          Ast.Encoding.constantEncoding(conversionOptions, encoding, cases),
        ),
      ],
    );

  let entity =
      (conversionOptions: conversionOptions, entity: TypeSystem.entity)
      : convertedEntity =>
    switch (entity) {
    | GenericType(genericType) =>
      switch (genericType.cases) {
      | [head, ...tail] =>
        switch (head, tail) {
        | (RecordCase(name, parameters), []) => {
            name: Some(conversionOptions.swiftOptions.typePrefix ++ name),
            node: record(conversionOptions, name, parameters),
          }
        | _ =>
          let genericParameters =
            TypeSystem.Access.entityGenericParameters(entity);
          let genericClause = genericParameters |> Format.joinWith(", ");
          let name =
            switch (genericParameters) {
            | [_, ..._] =>
              genericType.name
              ++ "<"
              ++ genericClause
              ++ ": Equatable & Codable>"
            | [] => genericType.name
            };
          let enumCases =
            genericType.cases |> List.map(enumCase(conversionOptions));
          /* Generate array encoding/decoding for linked lists */
          if (TypeSystem.Match.linkedList(entity)) {
            let constantCase =
              List.hd(TypeSystem.Access.constantCases(entity));
            let recursiveCase =
              List.hd(TypeSystem.Access.entityRecursiveCases(entity));
            let recursiveType =
              List.hd(
                TypeSystem.Access.typeCaseParameterEntities(recursiveCase),
              );
            {
              name: Some(conversionOptions.swiftOptions.typePrefix ++ name),
              node:
                EnumDeclaration({
                  "name": conversionOptions.swiftOptions.typePrefix ++ name,
                  "isIndirect": true,
                  "inherits": [
                    ProtocolCompositionType([
                      TypeName("Codable"),
                      TypeName("Equatable"),
                    ]),
                  ],
                  "modifier": Some(PublicModifier),
                  "body":
                    enumCases
                    @ [Empty]
                    @ linkedListCodable(
                        conversionOptions,
                        genericType.cases,
                        TypeSystem.Access.typeCaseName(recursiveCase),
                        TypeSystem.Access.typeCaseParameterEntityName(
                          recursiveType,
                        ),
                        TypeSystem.Access.typeCaseName(constantCase),
                      ),
                }),
            };
            /* Nullary types don't need encoding/decoding at all */
          } else if (TypeSystem.Match.nullary(entity)) {
            let constantCase =
              List.hd(TypeSystem.Access.constantCases(entity));
            {
              name: Some(conversionOptions.swiftOptions.typePrefix ++ name),
              node:
                EnumDeclaration({
                  "name": conversionOptions.swiftOptions.typePrefix ++ name,
                  "isIndirect": true,
                  "inherits": [
                    ProtocolCompositionType([
                      TypeName("Codable"),
                      TypeName("Equatable"),
                    ]),
                  ],
                  "modifier": Some(PublicModifier),
                  "body":
                    enumCases
                    @ [Empty]
                    @ nullaryCodable(
                        conversionOptions,
                        TypeSystem.Access.typeCaseName(constantCase),
                      ),
                }),
            };
            /* Types made of constants can be encoded as strings.
             * If a type has exactly 2 constants, then we use booleans.
             */
          } else if (TypeSystem.Match.boolean(entity)) {
            {
              name: Some(conversionOptions.swiftOptions.typePrefix ++ name),
              node:
                EnumDeclaration({
                  "name": conversionOptions.swiftOptions.typePrefix ++ name,
                  "isIndirect": true,
                  "inherits": [
                    ProtocolCompositionType([
                      TypeName("Codable"),
                      TypeName("Equatable"),
                    ]),
                  ],
                  "modifier": Some(PublicModifier),
                  "body":
                    enumCases
                    @ [Empty]
                    @ constantCodable(
                        conversionOptions,
                        BooleanEncoding,
                        genericType.cases,
                      ),
                }),
            };
          } else if (TypeSystem.Match.constant(entity)) {
            let needsCustomCodable =
              TypeSystem.Access.constantCases(entity)
              |> List.map(TypeSystem.Access.typeCaseName)
              |> List.exists(id => !SwiftFormat.isSafeIdentifier(id));
            {
              name: Some(conversionOptions.swiftOptions.typePrefix ++ name),
              node:
                EnumDeclaration({
                  "name": conversionOptions.swiftOptions.typePrefix ++ name,
                  "isIndirect": true,
                  "inherits": [
                    TypeName("String"),
                    ProtocolCompositionType([
                      TypeName("Codable"),
                      TypeName("Equatable"),
                    ]),
                  ],
                  "modifier": Some(PublicModifier),
                  "body":
                    enumCases
                    @ (
                      needsCustomCodable ?
                        [Empty]
                        @ constantCodable(
                            conversionOptions,
                            StringEncoding,
                            genericType.cases,
                          ) :
                        []
                    ),
                }),
            };
          } else {
            {
              name: Some(conversionOptions.swiftOptions.typePrefix ++ name),
              node:
                EnumDeclaration({
                  "name": conversionOptions.swiftOptions.typePrefix ++ name,
                  "isIndirect": true,
                  "inherits": [
                    ProtocolCompositionType([
                      TypeName("Codable"),
                      TypeName("Equatable"),
                    ]),
                  ],
                  "modifier": Some(PublicModifier),
                  "body":
                    enumCases
                    @ [Empty]
                    @ enumCodable(conversionOptions, genericType.cases),
                }),
            };
          };
        }
      | [] => {name: None, node: LineComment(genericType.name)}
      }
    | NativeType(nativeType) => {
        name: None,
        node:
          TypealiasDeclaration({
            "name": Naming.prefixedName(conversionOptions, nativeType.name),
            "modifier": Some(PublicModifier),
            "annotation": TypeName(nativeType.name),
          }),
      }
    };
};

type convertedType = {
  name: string,
  contents: string,
};

let render =
    (options: Options.options, file: TypeSystem.typesFile)
    : list(convertedType) => {
  let nativeTypeNames =
    file.types
    |> List.map(TypeSystem.Access.nativeTypeName)
    |> Sequence.compact;

  let conversionOptions = {
    nativeTypeNames,
    swiftOptions: options.swift,
    discriminant: options.discriminant,
    dataWrapper: options.dataWrapper,
  };

  let entities =
    file.types
    |> List.map(Build.entity(conversionOptions))
    |> List.map((convertedEntity: convertedEntity) =>
         switch (convertedEntity.name) {
         | Some(name) =>
           Some({
             name,
             contents: convertedEntity.node |> SwiftRender.toString,
           })
         | None => None
         }
       )
    |> Sequence.compact;

  entities;
};