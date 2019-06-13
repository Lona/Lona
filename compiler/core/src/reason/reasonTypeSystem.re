open Operators;
open ReasonAst;

type conversionOptions = {nativeTypeNames: list(string)};

let formatNativeType = string =>
  switch (string) {
  | "UUID" => Some("string")
  | "Bool" => Some("bool")
  | "CGFloat" => Some("float")
  | "String" => Some("string")
  | "Optional" => Some("option")
  | _ => None
  };

let formatDecoderIdentifier = string =>
  switch (string) {
  | "bool" => "Decode.bool"
  | "float" => "Decode.float"
  | "string" => "Decode.string"
  | "option" => "Decode.optional"
  | _ => string
  };

let formatTypeName = string =>
  formatNativeType(string) %? Format.lowerFirst(string);
let formatCaseName = Format.upperFirst;
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

let renderTypeCaseParameterEntity =
    (
      _options: conversionOptions,
      entityTypeAnnotation: typeAnnotation,
      entity: TypeSystem.typeCaseParameterEntity,
    )
    : renderedTypeCaseParameter =>
  switch (entity) {
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
              entityTypeAnnotation.parameters
              |> List.map((parameter: typeAnnotation) =>
                   formatDecoderIdentifier(parameter.name)
                 )
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
        decoder: IdentifierExpression({name: typeName}),
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

type renderedRecordTypeCaseParameter = {
  entry: recordTypeEntry,
  decoder: variableDeclaration,
};

let renderRecordTypeCaseParameter =
    (
      options: conversionOptions,
      entityTypeAnnotation: typeAnnotation,
      entity: TypeSystem.recordTypeCaseParameter,
    )
    : renderedRecordTypeCaseParameter => {
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
    decoder: {
      name: entity.key,
      annotation: None,
      initializer_:
        FunctionCallExpression({
          expression: IdentifierExpression({name: "Decode.field"}),
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
            IdentifierExpression({name: "data"}),
          ],
        }),
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
      entityTypeAnnotation: typeAnnotation,
      typeCase: TypeSystem.typeCase,
    )
    : renderedTypeCase =>
  switch (typeCase) {
  | NormalCase(name, parameters) =>
    let renderedParameters =
      parameters
      |> List.map((parameter: TypeSystem.normalTypeCaseParameter) =>
           renderTypeCaseParameterEntity(
             options,
             entityTypeAnnotation,
             parameter.value,
           )
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
        body: [
          switch (renderedParameters) {
          /* | [] => IdentifierExpression({name: "Unhandled"}) */
          | [a] =>
            Variable([
              {
                name: "decoded",
                annotation: None,
                initializer_:
                  FunctionCallExpression({
                    expression: IdentifierExpression({name: "Decode.array"}),
                    arguments: [a.decoder],
                  }),
              },
            ])
          | _ =>
            let decoderName =
              "tuple" ++ string_of_int(List.length(renderedParameters));

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
                annotation: None,
                initializer_:
                  FunctionCallExpression({
                    expression:
                      IdentifierExpression({name: "Decode." ++ decoderName}),
                    arguments:
                      renderedParameters
                      |> List.map((parameter: renderedTypeCaseParameter) =>
                           parameter.decoder
                         ),
                  }),
              },
            ]);
          },
          Expression(
            FunctionCallExpression({
              expression: IdentifierExpression({name: formatCaseName(name)}),
              arguments: [],
            }),
          ),
        ],
      },
    };
  | RecordCase(name, parameters) =>
    let renderedParameters =
      parameters
      |> List.map(
           renderRecordTypeCaseParameter(options, entityTypeAnnotation),
         );
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
        body:
          (
            renderedParameters
            |> List.map((parameter: renderedRecordTypeCaseParameter) =>
                 Variable([parameter.decoder])
               )
          )
          @ [
            Expression(
              FunctionCallExpression({
                expression:
                  IdentifierExpression({name: formatCaseName(name)}),
                arguments: [
                  LiteralExpression({
                    literal:
                      Record(
                        renderedParameters
                        |> List.map(
                             (parameter: renderedRecordTypeCaseParameter) =>
                             (
                               {
                                 key: parameter.decoder.name,
                                 value:
                                   IdentifierExpression({
                                     name: parameter.decoder.name,
                                   }),
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

type renderedDeclarations = {
  types: list(typeDeclaration),
  decoders: list(variableDeclaration),
};

let renderEntity =
    (options: conversionOptions, entity: TypeSystem.entity)
    : renderedDeclarations => {
  let genericTypeNames = TypeSystem.Access.entityGenericParameters(entity);
  let genericTypeAnnotations: list(typeAnnotation) =
    genericTypeNames
    |> List.map(name => {name: formatGenericName(name), parameters: []});

  switch (entity) {
  | GenericType(genericType) =>
    /* TODO: pass down entity instead of type annotation
       refactor, make function to get type annotation easily */
    let typeName = formatTypeName(genericType.name);
    let entityTypeAnnotation: typeAnnotation = {
      name: typeName,
      parameters: genericTypeAnnotations,
    };
    let renderedCases: list(renderedTypeCase) =
      genericType.cases
      |> List.map(renderTypeCase(options, entityTypeAnnotation));
    let cases =
      renderedCases
      |> List.map((result: renderedTypeCase) => result.variantCase);
    let recordTypes =
      renderedCases |> List.map((result: renderedTypeCase) => result.types);
    let decoderCases =
      renderedCases |> List.map((result: renderedTypeCase) => result.decoder);

    {
      types:
        (recordTypes |> List.concat)
        @ [{name: entityTypeAnnotation, value: VariantType({cases: cases})}],
      decoders: [
        {
          name: typeName,
          annotation: None,
          initializer_:
            FunctionExpression({
              parameters:
                (
                  genericTypeNames
                  |> List.map(name =>
                       {name: "decoder" ++ name, annotation: None}
                     )
                )
                @ [
                  {
                    name: "json",
                    annotation: Some({name: "Js.Json.t", parameters: []}),
                  },
                ],
              returnType: Some(entityTypeAnnotation),
              body: [
                Variable([
                  {
                    name: "case",
                    annotation: None,
                    initializer_:
                      FunctionCallExpression({
                        expression:
                          IdentifierExpression({name: "Decode.field"}),
                        arguments: [
                          LiteralExpression({literal: String("type")}),
                          IdentifierExpression({name: "Decode.string"}),
                          IdentifierExpression({name: "json"}),
                        ],
                      }),
                  },
                ]),
                Variable([
                  {
                    name: "data",
                    annotation: None,
                    initializer_:
                      FunctionCallExpression({
                        expression:
                          IdentifierExpression({name: "Decode.field"}),
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
        Open(["Json"]),
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