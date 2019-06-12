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

let formatTypeName = string =>
  formatNativeType(string) %? Format.lowerFirst(string);
let formatCaseName = Format.upperFirst;
let formatRecordTypeName = (name, parent) =>
  Format.lowerFirst(name) ++ Format.upperFirst(parent);
let formatGenericName = string => "'" ++ Format.lowerFirst(string);

let renderTypeCaseParameterEntity =
    (
      _options: conversionOptions,
      entityTypeAnnotation: typeAnnotation,
      entity: TypeSystem.typeCaseParameterEntity,
    )
    : typeAnnotation =>
  switch (entity) {
  | TypeReference(name, substitutions) =>
    let typeName = formatTypeName(name);

    if (typeName == entityTypeAnnotation.name) {
      entityTypeAnnotation;
    } else {
      let replacedGenerics: list(typeAnnotation) =
        substitutions
        |> List.map(
             (substitution: TypeSystem.genericTypeParameterSubstitution) =>
             formatTypeName(substitution.instance)
           )
        |> List.map(name => {name, parameters: []});
      {name: typeName, parameters: replacedGenerics};
    };
  | GenericReference(name) => {
      name: formatGenericName(name),
      parameters: [],
    }
  };

let renderRecordTypeCaseParameter =
    (
      options: conversionOptions,
      entityTypeAnnotation: typeAnnotation,
      entity: TypeSystem.recordTypeCaseParameter,
    )
    : recordTypeEntry => {
  key: entity.key,
  value:
    renderTypeCaseParameterEntity(
      options,
      entityTypeAnnotation,
      entity.value,
    ),
};

let renderTypeCase =
    (
      options: conversionOptions,
      entityTypeAnnotation: typeAnnotation,
      typeCase: TypeSystem.typeCase,
    )
    : (variantCase, list(typeDeclaration)) =>
  switch (typeCase) {
  | NormalCase(name, parameters) => (
      {
        name: formatCaseName(name),
        associatedData:
          parameters
          |> List.map((parameter: TypeSystem.normalTypeCaseParameter) =>
               renderTypeCaseParameterEntity(
                 options,
                 entityTypeAnnotation,
                 parameter.value,
               )
             ),
      },
      [],
    )
  | RecordCase(name, parameters) =>
    let recordTypeName =
      formatRecordTypeName(name, entityTypeAnnotation.name);
    (
      {
        name: formatCaseName(name),
        associatedData: [{name: recordTypeName, parameters: []}],
      },
      [
        {
          name: {
            name: recordTypeName,
            parameters: [],
          },
          value:
            RecordType({
              entries:
                parameters
                |> List.map(
                     renderRecordTypeCaseParameter(
                       options,
                       entityTypeAnnotation,
                     ),
                   ),
            }),
        },
      ],
    );
  };

let renderEntity =
    (options: conversionOptions, entity: TypeSystem.entity)
    : list(typeDeclaration) => {
  let genericTypeNames = TypeSystem.Access.entityGenericParameters(entity);
  let genericTypeAnnotations: list(typeAnnotation) =
    genericTypeNames
    |> List.map(name => {name: formatGenericName(name), parameters: []});

  switch (entity) {
  | GenericType(genericType) =>
    let entityTypeAnnotation: typeAnnotation = {
      name: formatTypeName(genericType.name),
      parameters: genericTypeAnnotations,
    };
    let renderedCases =
      genericType.cases
      |> List.map(renderTypeCase(options, entityTypeAnnotation));
    let cases = renderedCases |> List.map(((case, _)) => case);
    let recordTypes =
      renderedCases |> List.map(((_, recordType)) => recordType);

    (recordTypes |> List.concat)
    @ [{name: entityTypeAnnotation, value: VariantType({cases: cases})}];
  | NativeType(value) => []
  };
};

let renderTypes = (file: TypeSystem.typesFile): ReasonAst.declaration => {
  let nativeTypeNames =
    file.types
    |> List.map(TypeSystem.Access.nativeTypeName)
    |> Sequence.compact;

  let conversionOptions = {nativeTypeNames: nativeTypeNames};

  TypeDeclaration(
    file.types |> List.map(renderEntity(conversionOptions)) |> List.concat,
  );
};

let renderToString = (file: TypeSystem.typesFile): string =>
  renderTypes(file) |> ReasonRender.renderDeclaration |> ReasonRender.toString;