open Operators;
open ReasonAst;

type conversionOptions = {nativeTypeNames: list(string)};

let formatNativeType = string =>
  switch (string) {
  | "UUID" => Some("string")
  | "Bool" => Some("bool")
  | "CGFloat" => Some("number")
  | "String" => Some("string")
  | "Optional" => Some("option")
  | _ => None
  };

let formatDecoderIdentifier = string =>
  switch (string) {
  | "bool" => "Json.Decode.bool"
  | "float" => "Json.Decode.float"
  | "string" => "Json.Decode.string"
  | "option" => "Json.Decode.optional"
  | _ => string
  };

let formatTypeName = string =>
  formatNativeType(string) %? Format.upperFirst(string);
let formatCaseName = Format.lowerFirst;
let formatRecordTypeName = (name, parent) => Format.upperFirst(name);
let formatGenericName = string => "'" ++ Format.lowerFirst(string);

/* type renderedTypeCaseParameter = {
   annotation: typeAnnotation,
   decoder: expression, */
/* }; */

let typeAnnotationForEntity =
    (_options: conversionOptions, entity: TypeSystem.entity)
    : JavaScriptAst.typeReference => {
  let genericTypeNames = TypeSystem.Access.entityGenericParameters(entity);
  let genericTypeAnnotations: list(JavaScriptAst.type_) =
    genericTypeNames
    |> List.map(name =>
         JavaScriptAst.TypeReference({
           name: formatGenericName(name),
           arguments: [],
         })
       );

  switch (entity) {
  | GenericType(genericType) =>
    /* TODO: pass down entity instead of type annotation
       refactor, make function to get type annotation easily */
    let typeName = formatTypeName(genericType.name);
    {name: typeName, arguments: genericTypeAnnotations};
  | NativeType(nativeType) =>
    let typeName = formatTypeName(nativeType.name);
    {name: typeName, arguments: genericTypeAnnotations};
  };
};

let renderTypeCaseParameterEntity =
    (
      options: conversionOptions,
      entity: TypeSystem.entity,
      typeCaseParameterEntity: TypeSystem.typeCaseParameterEntity,
    )
    : JavaScriptAst.type_ => {
  let genericTypeNames = TypeSystem.Access.entityGenericParameters(entity);
  let entityTypeAnnotation = typeAnnotationForEntity(options, entity);
  switch (typeCaseParameterEntity) {
  | TypeReference(name, substitutions) =>
    let typeName = formatTypeName(name);

    if (typeName == entityTypeAnnotation.name) {
      TypeReference(entityTypeAnnotation);
    } else {
      let replacedGenerics: list(JavaScriptAst.type_) =
        substitutions
        |> List.map(
             (substitution: TypeSystem.genericTypeParameterSubstitution) =>
             formatTypeName(substitution.instance)
           )
        |> List.map(name =>
             JavaScriptAst.TypeReference({name, arguments: []})
           );

      TypeReference({name: typeName, arguments: replacedGenerics});
    };
  | GenericReference(name) =>
    TypeReference({name: formatGenericName(name), arguments: []})
  };
};

let renderRecordTypeCaseParameter =
    (
      options: conversionOptions,
      entityTypeAnnotation: TypeSystem.entity,
      entity: TypeSystem.recordTypeCaseParameter,
    )
    : JavaScriptAst.typeMember => {
  let isOptional =
    TypeSystem.Access.typeCaseParameterEntityName(entity.value) == "Optional";

  let rendered: JavaScriptAst.type_ =
    renderTypeCaseParameterEntity(
      options,
      entityTypeAnnotation,
      entity.value,
    );
  PropertySignature({name: entity.key, type_: Some(rendered)});
};

type renderedTypeCase = {
  variantCase: JavaScriptAst.type_,
  interfaces: list(JavaScriptAst.interfaceDeclaration),
  aliases: list(JavaScriptAst.typeAliasDeclaration),
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
    {
      variantCase:
        ObjectType({
          members: [
            PropertySignature({
              name: "type",
              type_: Some(LiteralType(formatCaseName(name))),
            }),
            PropertySignature({
              name: "value",
              type_:
                Some(
                  switch (renderedParameters) {
                  | [value] => value
                  | _ => TupleType(renderedParameters)
                  },
                ),
            }),
          ],
        }),
      interfaces: [],
      aliases: [],
    };
  /* {
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
     }; */
  | RecordCase(name, parameters) =>
    let renderedParameters =
      parameters |> List.map(renderRecordTypeCaseParameter(options, entity));
    let recordTypeName =
      formatRecordTypeName(name, entityTypeAnnotation.name);
    {
      variantCase:
        ObjectType({
          members: [
            PropertySignature({
              name: "type",
              type_: Some(LiteralType(formatCaseName(name))),
            }),
            PropertySignature({
              name: "value",
              type_: Some(ObjectType({members: renderedParameters})),
            }),
          ],
        }),
      interfaces: [],
      aliases: [],
    };
  };
};

type renderedDeclarations = {
  types: list(typeDeclaration),
  decoders: list(variableDeclaration),
};

let renderEntity =
    (options: conversionOptions, entity: TypeSystem.entity)
    : list(JavaScriptAst.node) => {
  let genericTypeNames = TypeSystem.Access.entityGenericParameters(entity);
  let entityTypeAnnotation = typeAnnotationForEntity(options, entity);

  switch (entity) {
  | GenericType(genericType) =>
    /* TODO: pass down entity instead of type annotation
       refactor, make function to get type annotation easily */
    /* let typeName = formatTypeName(genericType.name); */
    let renderedCases: list(renderedTypeCase) =
      genericType.cases |> List.map(renderTypeCase(options, entity));
    let interfaces =
      renderedCases
      |> List.map((result: renderedTypeCase) => result.interfaces)
      |> List.concat
      |> List.map(x => JavaScriptAst.InterfaceDeclaration(x));
    let aliases =
      renderedCases
      |> List.map((result: renderedTypeCase) => result.aliases)
      |> List.concat
      |> List.map(x => JavaScriptAst.TypeAliasDeclaration(x));
    let cases =
      renderedCases
      |> List.map((result: renderedTypeCase) => result.variantCase);
    let types = interfaces @ aliases;

    if (TypeSystem.Match.singleRecord(entity)) {
      switch (entity) {
      | GenericType({name: _, cases: [RecordCase(name, parameters)]}) =>
        let renderedParameters =
          parameters
          |> List.map(renderRecordTypeCaseParameter(options, entity));
        let recordTypeName =
          formatRecordTypeName(name, entityTypeAnnotation.name);

        [
          InterfaceDeclaration({
            identifier: recordTypeName,
            typeParameters: entityTypeAnnotation.arguments,
            objectType: {
              members: renderedParameters,
            },
          }),
        ];
      | _ => raise(Not_found)
      };
    } else if (TypeSystem.Match.constant(entity)) {
      let typeCases = TypeSystem.Access.constantCases(entity);
      switch (entity) {
      | GenericType({name}) =>
        let recordTypeName =
          formatRecordTypeName(name, entityTypeAnnotation.name);
        [
          TypeAliasDeclaration({
            identifier: recordTypeName,
            typeParameters: entityTypeAnnotation.arguments,
            type_:
              UnionType(
                typeCases
                |> List.map(TypeSystem.Access.typeCaseName)
                |> List.map(string => JavaScriptAst.LiteralType(string)),
              ),
          }),
        ];
      | _ => raise(Not_found)
      };
    } else {
      [
        TypeAliasDeclaration({
          identifier: entityTypeAnnotation.name,
          typeParameters: entityTypeAnnotation.arguments,
          type_: UnionType(cases),
        }),
      ];
    };
  | NativeType(_) => []
  };
};

let renderTypes = (file: TypeSystem.typesFile): list(JavaScriptAst.node) => {
  let nativeTypeNames =
    file.types
    |> List.map(TypeSystem.Access.nativeTypeName)
    |> Sequence.compact;

  let conversionOptions = {nativeTypeNames: nativeTypeNames};

  file.types |> List.map(renderEntity(conversionOptions)) |> List.concat;
};

let renderToString = (file: TypeSystem.typesFile): string =>
  renderTypes(file)
  |> List.map(node => JavaScriptAst.ExportNamedDeclaration(node))
  |> List.map(JavaScriptRender.toString)
  |> Format.joinWith("\n\n");