type genericTypeParameterSubstitution = {
  generic: string,
  instance: string,
};

type typeCaseParameterEntity =
  | TypeReference(string, list(genericTypeParameterSubstitution))
  | GenericReference(string);

type normalTypeCaseParameter = {value: typeCaseParameterEntity};

type recordTypeCaseParameter = {
  key: string,
  value: typeCaseParameterEntity,
};

type typeCase =
  | NormalCase(string, list(normalTypeCaseParameter))
  | RecordCase(string, list(recordTypeCaseParameter));

type genericType = {
  name: string,
  cases: list(typeCase),
};

type nativeType = {name: string};

type entity =
  | GenericType(genericType)
  | NativeType(nativeType);

type typesFile = {types: list(entity)};

module Access = {
  let typeCaseName = (typeCase: typeCase): string =>
    switch (typeCase) {
    | NormalCase(name, _)
    | RecordCase(name, _) => name
    };

  let typeCaseParameterCount = (typeCase: typeCase): int =>
    switch (typeCase) {
    | NormalCase(_, parameters) => List.length(parameters)
    | RecordCase(_, parameters) => List.length(parameters)
    };

  let entityRecords =
      (entity: entity): list((string, list(recordTypeCaseParameter))) =>
    switch (entity) {
    | GenericType(genericType) =>
      genericType.cases
      |> List.map(case =>
           switch (case) {
           | NormalCase(_) => []
           | RecordCase(name, parameters) => [(name, parameters)]
           }
         )
      |> List.concat
    | NativeType(_) => []
    };

  let typeCaseParameterEntities =
      (case: typeCase): list(typeCaseParameterEntity) =>
    switch (case) {
    | NormalCase(_, parameters) =>
      parameters
      |> List.map((parameter: normalTypeCaseParameter) => parameter.value)
    | RecordCase(_, parameters) =>
      parameters
      |> List.map((parameter: recordTypeCaseParameter) => parameter.value)
    };

  let typeCaseParameterEntityName =
      (parameterEntity: typeCaseParameterEntity): string =>
    switch (parameterEntity) {
    | TypeReference(name, _) => name
    | GenericReference(name) => name
    };

  let entityGenericParameters = (entity: entity): list(string) =>
    switch (entity) {
    | GenericType(genericType) =>
      genericType.cases
      |> List.map(case =>
           case
           |> typeCaseParameterEntities
           |> List.map(parameterEntity =>
                switch (parameterEntity) {
                | TypeReference(_) => []
                | GenericReference(generic) => [generic]
                }
              )
           |> List.concat
         )
      |> List.concat
    | NativeType(_) => []
    };

  let parameterizedCases = (entity: entity): list(typeCase) =>
    switch (entity) {
    | GenericType(genericType) =>
      genericType.cases
      |> List.filter((case: typeCase) => typeCaseParameterCount(case) > 0)
    | NativeType(_) => []
    };

  let constantCases = (entity: entity): list(typeCase) =>
    switch (entity) {
    | GenericType(genericType) =>
      genericType.cases
      |> List.filter((case: typeCase) => typeCaseParameterCount(case) == 0)
    | NativeType(_) => []
    };

  let entityRecursiveCases = (entity: entity): list(typeCase) =>
    switch (entity) {
    | GenericType(genericType) =>
      genericType.cases
      |> List.map(case =>
           case
           |> typeCaseParameterEntities
           |> List.map(parameterEntity =>
                switch (parameterEntity) {
                | TypeReference(name, _) when name == genericType.name => [
                    case,
                  ]
                | TypeReference(_) => []
                | GenericReference(_) => []
                }
              )
           |> List.concat
         )
      |> List.concat
    | NativeType(_) => []
    };
};

module Match = {
  let nativeTypeName = (name: string, entity: entity): bool =>
    switch (entity) {
    | GenericType(_) => false
    | NativeType(nativeType) => nativeType.name == name
    };

  let genericTypeCaseNames = (names: list(string), entity: entity): bool =>
    switch (entity) {
    | GenericType(genericType) =>
      List.length(names) == List.length(genericType.cases)
      && names
      |> List.for_all(name => {
           let caseNames = genericType.cases |> List.map(Access.typeCaseName);
           List.mem(name, caseNames);
         })
    | NativeType(_) => false
    };

  let linkedList = (entity: entity): bool =>
    switch (entity) {
    | GenericType(genericType) =>
      List.length(genericType.cases) == 2
      && List.length(Access.entityRecursiveCases(entity)) == 1
      && List.length(Access.constantCases(entity)) == 1
    | NativeType(_) => false
    };

  let nullary = (entity: entity): bool =>
    switch (entity) {
    | GenericType(genericType) =>
      List.length(genericType.cases) == 1
      && List.length(Access.constantCases(entity)) == 1
    | NativeType(_) => false
    };

  let constant = (entity: entity): bool =>
    switch (entity) {
    | GenericType(genericType) =>
      List.length(genericType.cases)
      == List.length(Access.constantCases(entity))
    | NativeType(_) => false
    };

  let boolean = (entity: entity): bool =>
    switch (entity) {
    | GenericType(genericType) =>
      List.length(genericType.cases) == 2
      && List.length(Access.constantCases(entity)) == 2
    | NativeType(_) => false
    };

  let optional = (entity: entity): bool =>
    switch (entity) {
    | GenericType(genericType) =>
      List.length(genericType.cases) == 2
      && List.length(Access.parameterizedCases(entity)) == 1
      && List.length(Access.constantCases(entity)) == 1
    | NativeType(_) => false
    };
};

module Decode = {
  open Json.Decode;

  exception Error(string);

  let genericTypeParameterSubstitution =
      (json: Js.Json.t): genericTypeParameterSubstitution => {
    let generic = json |> field("generic", string);
    let instance = json |> field("instance", string);
    {generic, instance};
  };

  let typeCaseParameterEntity = (json: Js.Json.t): typeCaseParameterEntity => {
    let case = json |> field("case", string);
    let name = json |> field("name", string);
    switch (case) {
    | "generic" => GenericReference(name)
    | "type" =>
      TypeReference(
        name,
        json
        |> field("substitutions", list(genericTypeParameterSubstitution)),
      )
    | _ => raise(Error("Failed to decode 'entity' of type: " ++ case))
    };
  };

  let normalTypeCaseParameter = (json: Js.Json.t): normalTypeCaseParameter => {
    let value = json |> field("value", typeCaseParameterEntity);
    {value: value};
  };

  let recordTypeCaseParameter = (json: Js.Json.t): recordTypeCaseParameter => {
    let value = json |> field("value", typeCaseParameterEntity);
    let key = json |> field("key", string);
    {key, value};
  };

  let typeCase = (json: Js.Json.t): typeCase => {
    let case = json |> field("case", string);
    let name = json |> field("name", string);
    switch (case) {
    | "normal" =>
      NormalCase(
        name,
        json |> field("params", list(normalTypeCaseParameter)),
      )
    | "record" =>
      RecordCase(
        name,
        json |> field("params", list(recordTypeCaseParameter)),
      )
    | _ => raise(Error("Failed to decode 'entity' of type: " ++ case))
    };
  };

  let nativeType = (json: Js.Json.t): nativeType => {
    let name = json |> field("name", string);
    {name: name};
  };

  let genericType = (json: Js.Json.t): genericType => {
    let name = json |> field("name", string);
    let cases = json |> field("cases", list(typeCase));
    {name, cases};
  };

  let entity = (json: Js.Json.t): entity => {
    let case = json |> field("case", string);
    switch (case) {
    | "type" => GenericType(json |> field("data", genericType))
    | "native" => NativeType(json |> field("data", nativeType))
    | _ => raise(Error("Failed to decode 'entity' of type: " ++ case))
    };
  };

  let typesFile = (json: Js.Json.t): typesFile => {
    let types = json |> field("types", list(entity));
    {types: types};
  };
};