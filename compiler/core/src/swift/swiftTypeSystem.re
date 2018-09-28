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
      "inherits": [],
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
            | [_, ..._] => genericType.name ++ "<" ++ genericClause ++ ">"
            | [] => genericType.name
            };
          EnumDeclaration({
            "name": swiftOptions.typePrefix ++ name,
            "isIndirect": true,
            "inherits": [],
            "modifier": Some(PublicModifier),
            "body": genericType.cases |> List.map(enumCase(swiftOptions)),
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