type file = {types: list(Types.lonaType)};

exception UnknownType(string);

module Decode = {
  open Json.Decode;

  let rec lonaType = json: Types.lonaType => {
    let namedType = json: Types.lonaType => {
      let named = field("alias", string, json);
      let ltype = field("of", lonaType, json);
      Named(named, ltype);
    };
    let arrayType = json: Types.lonaType => {
      let ltype = field("of", lonaType, json);
      Array(ltype);
    };

    let variantType = json: Types.lonaType => {
      let variantCase = json: Types.lonaVariantCase =>
        switch (json |> optional(string)) {
        | Some(tag) => {tag, ltype: Types.unitType}
        | None => {
            tag: field("case", string, json),
            ltype: field("type", lonaType, json),
          }
        };
      let cases =
        switch (json |> optional(field("cases", list(variantCase)))) {
        | Some(decoded) => decoded
        | None => []
        };
      Variant(cases);
    };
    let functionType = json: Types.lonaType => {
      let argumentType = json: Types.lonaFunctionParameter => {
        label: field("label", string, json),
        ltype: field("type", lonaType, json),
      };
      let arguments =
        switch (json |> optional(field("parameters", list(argumentType)))) {
        | Some(decoded) => decoded
        | None => []
        };
      let returnType =
        switch (json |> optional(field("returnType", lonaType))) {
        | Some(decoded) => decoded
        | None => Types.undefinedType
        };
      Function(arguments, returnType);
    };
    let referenceType = json: Types.lonaType =>
      json
      |> string
      |> (
        x =>
          switch (x) {
          | "URL" => Types.urlType
          | "Color" => Types.colorType
          | _ => Reference(x)
          }
      );
    let otherType = json: Types.lonaType => {
      let name = field("name", string, json);
      switch (name) {
      | "Named" => namedType(json)
      | "Enum"
      | "Variant" => variantType(json)
      | "Function" => functionType(json)
      | "Array" => arrayType(json)
      | _ =>
        Js.log("Unknown custom lona type: " ++ name);
        raise(UnknownType(name));
      };
    };
    json |> oneOf([referenceType, otherType]);
  };
};

let parseFile = (content: string): file => {
  let parsed = content |> Js.Json.parseExn;

  Json.Decode.{types: field("types", list(Decode.lonaType), parsed)};
};

module TypeSystem = {
  let toTypeSystem = (lonaType: Types.lonaType) =>
    switch (lonaType) {
    | Named(name, Variant(cases)) =>
      Some(
        TypeSystem.GenericType({
          name,
          cases:
            cases
            |> List.map((case: Types.lonaVariantCase) =>
                 TypeSystem.NormalCase(
                   case.tag,
                   switch (case.ltype) {
                   | Reference("Unit") => []
                   | Reference(name) =>
                     let name =
                       switch (name) {
                       | "Number" => "CGFloat"
                       | "WholeNumber" => "Int"
                       | _ => name
                       };

                     [{value: TypeSystem.TypeReference(name, [])}];
                   | _ => []
                   },
                 )
               ),
        }),
      )
    | _ => None
    };

  let toTypeSystemFile = (file: file): TypeSystem.typesFile => {
    types: file.types |> List.map(toTypeSystem) |> Sequence.compact,
  };
};

let find = (types: list(Types.lonaType), name: string) =>
  switch (
    types
    |> List.find(lonaType =>
         switch (lonaType) {
         | Types.Named(alias, _) when alias == name => true
         | _ => false
         }
       )
  ) {
  | lonaType => Some(lonaType)
  | exception Not_found => None
  };

let resolveType = (types: list(Types.lonaType), typeName: string) => {
  let match = find(types, typeName);
  switch (match) {
  | Some(Named(_, referencedType)) => Some(referencedType)
  | Some(_) => None
  | None => None
  };
};

let rec unwrapNamedType = (ltype: Types.lonaType): Types.lonaType =>
  switch (ltype) {
  | Named(_, referencedType) => unwrapNamedType(referencedType)
  | _ => ltype
  };