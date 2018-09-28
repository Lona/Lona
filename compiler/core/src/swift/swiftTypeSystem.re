module Ast = {
  open SwiftAst;

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

  let encodingContainer = () =>
    VariableDeclaration({
      "modifiers": [],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier("container"),
          "annotation": None,
        }),
      "init":
        Some(
          FunctionCallExpression({
            "name":
              MemberExpression([
                SwiftIdentifier("encoder"),
                SwiftIdentifier("container"),
              ]),
            "arguments": [
              FunctionCallArgument({
                "name": Some(SwiftIdentifier("keyedBy")),
                "value":
                  MemberExpression([
                    SwiftIdentifier("CodingKeys"),
                    SwiftIdentifier("self"),
                  ]),
              }),
            ],
          }),
        ),
      "block": None,
    });

  let decodingContainer = () =>
    ConstantDeclaration({
      "modifiers": [],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier("container"),
          "annotation": None,
        }),
      "init":
        Some(
          FunctionCallExpression({
            "name":
              MemberExpression([
                SwiftIdentifier("decoder"),
                SwiftIdentifier("container"),
              ]),
            "arguments": [
              FunctionCallArgument({
                "name": Some(SwiftIdentifier("keyedBy")),
                "value":
                  MemberExpression([
                    SwiftIdentifier("CodingKeys"),
                    SwiftIdentifier("self"),
                  ]),
              }),
            ],
          }),
        ),
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
      "patterns": [ExpressionPattern({"value": SwiftIdentifier("type")})],
      "statements":
        [containerEncode(LiteralExpression(String(caseName)), "type")]
        @ enumCaseDataEncoding(typeCase),
    });
  };

  let enumCaseDecoding = (typeCase: TypeSystem.typeCase): SwiftAst.node => {
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
        ExpressionPattern({"value": LiteralExpression(String(caseName))}),
      ],
      "statements":
        [containerDecode(LiteralExpression(String(caseName)), "type")]
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
    encodingContainer(),
    Empty,
    SwitchStatement({
      "expression": SwiftIdentifier("self"),
      "cases": typeCases |> List.map(enumCaseEncoding),
    }),
  ];

  let enumDecoding =
      (typeCases: list(TypeSystem.typeCase)): list(SwiftAst.node) => [
    decodingContainer(),
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
      "cases": typeCases |> List.map(enumCaseDecoding),
    }),
  ];

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

  let prefixedName = (swiftOptions: SwiftOptions.options, name: string) =>
    swiftOptions.typePrefix ++ name;

  let typeName =
      (
        swiftOptions: SwiftOptions.options,
        useTypePrefix: bool,
        typeCaseParameterEntity: TypeSystem.typeCaseParameterEntity,
      )
      : SwiftAst.typeAnnotation => {
    let formattedName = name =>
      useTypePrefix ? prefixedName(swiftOptions, name) : name;
    switch (typeCaseParameterEntity) {
    | TypeSystem.TypeReference(name, []) => TypeName(formattedName(name))
    | TypeSystem.TypeReference(name, parameters) =>
      let generics =
        parameters
        |> List.map((parameter: TypeSystem.genericTypeParameterSubstitution) =>
             formattedName(parameter.instance)
           )
        |> Format.joinWith(", ");
      TypeName(formattedName(name) ++ "<" ++ generics ++ ">");
    | GenericReference(name) => TypeName(name)
    };
  };

  let record =
      (
        swiftOptions: SwiftOptions.options,
        name: string,
        parameters: list(TypeSystem.recordTypeCaseParameter),
      )
      : SwiftAst.node =>
    StructDeclaration({
      "name": name |> Format.upperFirst |> prefixedName(swiftOptions),
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
                     Some(parameter.value |> typeName(swiftOptions, true)),
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
             parameter.value |> typeName(swiftOptions, true)
           )
      };
    EnumCase({
      "name": SwiftIdentifier(name),
      "parameters": parameterCount > 0 ? Some(TupleType(parameters)) : None,
      "value": None,
    });
  };

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
          EnumDeclaration({
            "name": swiftOptions.typePrefix ++ name,
            "isIndirect": true,
            "inherits": [TypeName("Codable")],
            "modifier": Some(PublicModifier),
            "body":
              (genericType.cases |> List.map(enumCase(swiftOptions)))
              @ [
                Empty,
                LineComment("MARK: Codable"),
                Empty,
                Ast.codingKeys(["type", "data"]),
                Empty,
                Ast.decodableInitializer(
                  Ast.enumDecoding(genericType.cases),
                ),
                Empty,
                Ast.encodableFunction(Ast.enumEncoding(genericType.cases)),
              ],
          });
        }
      | [] => LineComment(genericType.name)
      }
    | NativeType(nativeType) =>
      TypealiasDeclaration({
        "name": prefixedName(swiftOptions, nativeType.name),
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