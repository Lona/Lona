type codingContainer =
  | Keyed
  | Unkeyed
  | SingleValue
  | NestedKeyed
  | NestedUnkeyed;

module Naming = {
  let prefixedName = (swiftOptions: SwiftOptions.options, name: string) =>
    swiftOptions.typePrefix ++ name;

  let prefixedType =
      (
        swiftOptions: SwiftOptions.options,
        useTypePrefix: bool,
        typeCaseParameterEntity: TypeSystem.typeCaseParameterEntity,
      )
      : string => {
    let formattedName = name =>
      useTypePrefix ? prefixedName(swiftOptions, name) : name;
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

  let typeName =
      (
        swiftOptions: SwiftOptions.options,
        useTypePrefix: bool,
        typeCaseParameterEntity: TypeSystem.typeCaseParameterEntity,
      )
      : SwiftAst.typeAnnotation =>
    TypeName(
      prefixedType(swiftOptions, useTypePrefix, typeCaseParameterEntity),
    );

  let codingContainer = (container: codingContainer): string =>
    switch (container) {
    | Keyed => "container"
    | Unkeyed => "unkeyedContainer"
    | SingleValue => "singleValueContainer"
    | NestedKeyed => "nestedContainer"
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

    let decodingContainer = (variableName: string, container: codingContainer) => {
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
                    SwiftIdentifier("decoder"),
                    SwiftIdentifier(container |> Naming.codingContainer),
                  ]),
                "arguments":
                  switch (container) {
                  | Keyed
                  | NestedKeyed => [
                      FunctionCallArgument({
                        "name": Some(SwiftIdentifier("keyedBy")),
                        "value":
                          MemberExpression([
                            SwiftIdentifier("CodingKeys"),
                            SwiftIdentifier("self"),
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

    let containerDecode = (value: node, codingKey: string) =>
      TryExpression({
        "expression":
          FunctionCallExpression({
            "name":
              MemberExpression([
                SwiftIdentifier("container"),
                SwiftIdentifier("decode"),
              ]),
            "arguments": [
              FunctionCallArgument({"name": None, "value": value}),
              FunctionCallArgument({
                "name": Some(SwiftIdentifier("forKey")),
                "value": SwiftIdentifier("." ++ codingKey),
              }),
            ],
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
        (swiftOptions: SwiftOptions.options, typeCase: TypeSystem.typeCase)
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
                         |> Naming.prefixedType(swiftOptions, true),
                       ),
                       SwiftIdentifier("self"),
                     ]),
                   ),
               })
             );
        [nestedUnkeyedDecodingContainer("container", "data")]
        @ [
          BinaryExpression({
            "left": SwiftIdentifier("self"),
            "operator": "=",
            "right":
              FunctionCallExpression({
                "name": SwiftIdentifier("." ++ name),
                "arguments": decodeParameters,
              }),
          }),
        ];
      /* self = .value(try container.decode(Value.self, forKey: .data)) */
      | NormalCase(name, [parameter]) => [
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
                        MemberExpression([
                          SwiftIdentifier(
                            parameter.value
                            |> Naming.prefixedType(swiftOptions, true),
                          ),
                          SwiftIdentifier("self"),
                        ]),
                        "data",
                      ),
                  }),
                ],
              }),
          }),
        ]
      | NormalCase(name, []) => [
          BinaryExpression({
            "left": SwiftIdentifier("self"),
            "operator": "=",
            "right": SwiftIdentifier("." ++ name),
          }),
        ]
      | RecordCase(_, _) => [
          containerDecode(SwiftIdentifier("value"), "data"),
        ]
      };

    let enumCaseDecoding =
        (swiftOptions: SwiftOptions.options, typeCase: TypeSystem.typeCase)
        : SwiftAst.node => {
      let caseName = typeCase |> TypeSystem.Access.typeCaseName;

      CaseLabel({
        "patterns": [
          ExpressionPattern({"value": LiteralExpression(String(caseName))}),
        ],
        "statements": enumCaseDataDecoding(swiftOptions, typeCase),
      });
    };

    let enumDecoding =
        (
          swiftOptions: SwiftOptions.options,
          typeCases: list(TypeSystem.typeCase),
        )
        : list(SwiftAst.node) => [
      decodingContainer("container", Keyed),
      ConstantDeclaration({
        "modifiers": [],
        "pattern":
          IdentifierPattern({
            "identifier": SwiftIdentifier("type"),
            "annotation": None,
          }),
        "init":
          Some(
            containerDecode(
              MemberExpression([
                SwiftIdentifier("String"),
                SwiftIdentifier("self"),
              ]),
              "type",
            ),
          ),
      }),
      Empty,
      SwitchStatement({
        "expression": SwiftIdentifier("type"),
        "cases":
          (typeCases |> List.map(enumCaseDecoding(swiftOptions)))
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

    let linkedListDecoding =
        (
          swiftOptions: SwiftOptions.options,
          typeCases: list(TypeSystem.typeCase),
          recursiveCaseName: string,
          recursiveTypeName: string,
          constantCaseName: string,
        )
        : list(SwiftAst.node) => [
      decodingContainer("unkeyedContainer", Unkeyed),
      Empty,
      BinaryExpression({
        "left": SwiftIdentifier("self"),
        "operator": "=",
        "right": SwiftIdentifier("." ++ constantCaseName),
      }),
      Empty,
      WhileStatement({
        "condition":
          MemberExpression([
            SwiftIdentifier("!unkeyedContainer"),
            SwiftIdentifier("isAtEnd"),
          ]),
        "block": [
          ConstantDeclaration({
            "modifiers": [],
            "pattern":
              IdentifierPattern({
                "identifier": SwiftIdentifier("item"),
                "annotation": None,
              }),
            "init":
              Some(
                unkeyedContainerDecode(
                  MemberExpression([
                    SwiftIdentifier(recursiveTypeName),
                    SwiftIdentifier("self"),
                  ]),
                ),
              ),
          }),
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
  };

  module Encoding = {
    /* Produces:
     * public func encode(to encoder: Encoder) throws {}
     */
    let encodableFunction = (body: list(SwiftAst.node)) =>
      FunctionDeclaration({
        "name": "encode",
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

    let encodingContainer = (variableName: string, container: codingContainer) =>
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
                  SwiftIdentifier("encoder"),
                  SwiftIdentifier(container |> Naming.codingContainer),
                ]),
              "arguments":
                switch (container) {
                | Keyed
                | NestedKeyed => [
                    FunctionCallArgument({
                      "name": Some(SwiftIdentifier("keyedBy")),
                      "value":
                        MemberExpression([
                          SwiftIdentifier("CodingKeys"),
                          SwiftIdentifier("self"),
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

    let containerEncode = (value: node, codingKey: string) =>
      TryExpression({
        "expression":
          FunctionCallExpression({
            "name":
              MemberExpression([
                SwiftIdentifier("container"),
                SwiftIdentifier("encode"),
              ]),
            "arguments": [
              FunctionCallArgument({"name": None, "value": value}),
              FunctionCallArgument({
                "name": Some(SwiftIdentifier("forKey")),
                "value": SwiftIdentifier("." ++ codingKey),
              }),
            ],
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
        (typeCase: TypeSystem.typeCase): list(SwiftAst.node) =>
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
        [nestedUnkeyedEncodingContainer("container", "data")]
        @ encodeParameters;
      /* A single parameter is encoded automatically */
      | NormalCase(_, [_]) => [
          containerEncode(SwiftIdentifier("value"), "data"),
        ]
      | NormalCase(_, []) => []
      | RecordCase(_, _) => [
          containerEncode(SwiftIdentifier("value"), "data"),
        ]
      };

    /* case .undefined:
         try container.encode("undefined", forKey: .type)
       */
    let enumCaseEncoding = (typeCase: TypeSystem.typeCase): SwiftAst.node => {
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
          [containerEncode(LiteralExpression(String(caseName)), "type")]
          @ enumCaseDataEncoding(typeCase),
      });
    };

    /* var container = encoder.container(keyedBy: CodingKeys.self)
       switch self {
       ...
       }
       */
    let enumEncoding =
        (typeCases: list(TypeSystem.typeCase)): list(SwiftAst.node) => [
      encodingContainer("container", Keyed),
      Empty,
      SwitchStatement({
        "expression": SwiftIdentifier("self"),
        "cases": typeCases |> List.map(enumCaseEncoding),
      }),
    ];

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
      encodingContainer("unkeyedContainer", Unkeyed),
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
  };

  let codingKeys = (names: list(string)) =>
    EnumDeclaration({
      "name": "CodingKeys",
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
        swiftOptions: SwiftOptions.options,
        name: string,
        parameters: list(TypeSystem.recordTypeCaseParameter),
      )
      : SwiftAst.node =>
    StructDeclaration({
      "name": name |> Format.upperFirst |> Naming.prefixedName(swiftOptions),
      "inherits": [TypeName("Codable")],
      "modifier": Some(PublicModifier),
      "body":
        parameters
        |> List.map((parameter: TypeSystem.recordTypeCaseParameter) =>
             VariableDeclaration({
               "modifiers": [AccessLevelModifier(PublicModifier)],
               "pattern":
                 IdentifierPattern({
                   "identifier": SwiftIdentifier(parameter.key),
                   "annotation":
                     Some(
                       parameter.value |> Naming.typeName(swiftOptions, true),
                     ),
                 }),
               "init": None,
               "block": None,
             })
           ),
    });

  let enumCase =
      (swiftOptions: SwiftOptions.options, typeCase: TypeSystem.typeCase)
      : SwiftAst.node => {
    let name = typeCase |> TypeSystem.Access.typeCaseName;
    let parameterCount =
      switch (typeCase) {
      | RecordCase(_, _) => 1
      | NormalCase(_, parameters) => List.length(parameters)
      };
    let parameters =
      switch (typeCase) {
      | RecordCase(name, _) => [TypeName(swiftOptions.typePrefix ++ name)]
      | NormalCase(_, parameters) =>
        parameters
        |> List.map((parameter: TypeSystem.normalTypeCaseParameter) =>
             parameter.value |> Naming.typeName(swiftOptions, true)
           )
      };
    EnumCase({
      "name": SwiftIdentifier(name),
      "parameters": parameterCount > 0 ? Some(TupleType(parameters)) : None,
      "value": None,
    });
  };

  let enumCodable =
      (swiftOptions: SwiftOptions.options, cases: list(TypeSystem.typeCase))
      : list(SwiftAst.node) =>
    SwiftDocument.join(
      Empty,
      [
        LineComment("MARK: Codable"),
        Ast.codingKeys(["type", "data"]),
        Ast.Decoding.decodableInitializer(
          Ast.Decoding.enumDecoding(swiftOptions, cases),
        ),
        Ast.Encoding.encodableFunction(Ast.Encoding.enumEncoding(cases)),
      ],
    );

  let linkedListCodable =
      (
        swiftOptions: SwiftOptions.options,
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
            swiftOptions,
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

  let entity =
      (swiftOptions: SwiftOptions.options, entity: TypeSystem.entity)
      : SwiftAst.node =>
    switch (entity) {
    | GenericType(genericType) =>
      switch (genericType.cases) {
      | [head, ...tail] =>
        switch (head, tail) {
        | (RecordCase(_), []) => LineComment("Single-case record")
        | _ =>
          let genericParameters =
            TypeSystem.Access.entityGenericParameters(entity);
          let genericClause = genericParameters |> Format.joinWith(", ");
          let name =
            switch (genericParameters) {
            | [_, ..._] =>
              genericType.name ++ "<" ++ genericClause ++ ": Codable>"
            | [] => genericType.name
            };
          let enumCases =
            genericType.cases |> List.map(enumCase(swiftOptions));
          /* Generate optimized encoding/decoding for linked lists */
          if (TypeSystem.Match.linkedList(entity)) {
            let constantCase =
              List.hd(TypeSystem.Access.constantCases(entity));
            let recursiveCase =
              List.hd(TypeSystem.Access.entityRecursiveCases(entity));
            let recursiveType =
              List.hd(
                TypeSystem.Access.typeCaseParameterEntities(recursiveCase),
              );
            EnumDeclaration({
              "name": swiftOptions.typePrefix ++ name,
              "isIndirect": true,
              "inherits": [TypeName("Codable")],
              "modifier": Some(PublicModifier),
              "body":
                enumCases
                @ linkedListCodable(
                    swiftOptions,
                    genericType.cases,
                    TypeSystem.Access.typeCaseName(recursiveCase),
                    TypeSystem.Access.typeCaseParameterEntityName(
                      recursiveType,
                    ),
                    TypeSystem.Access.typeCaseName(constantCase),
                  ),
            });
          } else {
            EnumDeclaration({
              "name": swiftOptions.typePrefix ++ name,
              "isIndirect": true,
              "inherits": [TypeName("Codable")],
              "modifier": Some(PublicModifier),
              "body":
                enumCases @ enumCodable(swiftOptions, genericType.cases),
            });
          };
        }
      | [] => LineComment(genericType.name)
      }
    | NativeType(nativeType) =>
      TypealiasDeclaration({
        "name": Naming.prefixedName(swiftOptions, nativeType.name),
        "modifier": Some(PublicModifier),
        "annotation": TypeName(nativeType.name),
      })
    };
};

let render =
    (swiftOptions: SwiftOptions.options, file: TypeSystem.typesFile): string => {
  let records =
    file.types |> List.map(TypeSystem.Access.entityRecords) |> List.concat;
  let structs =
    records
    |> List.map(((name: string, parameters)) =>
         Build.record(swiftOptions, name, parameters)
       );

  let ast =
    SwiftAst.(
      TopLevelDeclaration({
        "statements":
          SwiftDocument.join(
            Empty,
            structs @ (file.types |> List.map(Build.entity(swiftOptions))),
          ),
      })
    );
  SwiftRender.toString(ast);
};