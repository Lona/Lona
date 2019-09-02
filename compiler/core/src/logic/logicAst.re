type list('t) =
  | Next('t, list('t)) | Empty

and identifierIdentifier =
  { id: string, string: string, isPlaceholder: bool }

and identifier =
  | Identifier(identifierIdentifier)

and variableDeclaration =
  {
    id: string,
    name: pattern,
    annotation: option(typeAnnotation),
    initializer_: option(expression),
    comment: option(comment)
  }

and functionDeclaration =
  {
    id: string,
    name: pattern,
    returnType: typeAnnotation,
    genericParameters: list(genericParameter),
    parameters: list(functionParameter),
    block: list(statement),
    comment: option(comment)
  }

and enumerationDeclaration =
  {
    id: string,
    name: pattern,
    genericParameters: list(genericParameter),
    cases: list(enumerationCase),
    comment: option(comment)
  }

and namespaceDeclaration =
  { id: string, name: pattern, declarations: list(declaration) }

and placeholderDeclaration =
  { id: string }

and recordDeclaration =
  {
    id: string,
    name: pattern,
    genericParameters: list(genericParameter),
    declarations: list(declaration),
    comment: option(comment)
  }

and importDeclarationDeclaration =
  { id: string, name: pattern }

and declaration =
  | Variable(variableDeclaration)
  | Function(functionDeclaration)
  | Enumeration(enumerationDeclaration)
  | Namespace(namespaceDeclaration)
  | Placeholder(placeholderDeclaration)
  | Record(recordDeclaration)
  | ImportDeclaration(importDeclarationDeclaration)

and placeholderEnumerationCase =
  { id: string }

and enumerationCaseEnumerationCase =
  {
    id: string,
    name: pattern,
    associatedValueTypes: list(typeAnnotation),
    comment: option(comment)
  }

and enumerationCase =
  | Placeholder(placeholderEnumerationCase)
  | EnumerationCase(enumerationCaseEnumerationCase)

and patternPattern =
  { id: string, name: string }

and pattern =
  | Pattern(patternPattern)

and isEqualToBinaryOperator =
  { id: string }

and isNotEqualToBinaryOperator =
  { id: string }

and isLessThanBinaryOperator =
  { id: string }

and isGreaterThanBinaryOperator =
  { id: string }

and isLessThanOrEqualToBinaryOperator =
  { id: string }

and isGreaterThanOrEqualToBinaryOperator =
  { id: string }

and setEqualToBinaryOperator =
  { id: string }

and binaryOperator =
  | IsEqualTo(isEqualToBinaryOperator)
  | IsNotEqualTo(isNotEqualToBinaryOperator)
  | IsLessThan(isLessThanBinaryOperator)
  | IsGreaterThan(isGreaterThanBinaryOperator)
  | IsLessThanOrEqualTo(isLessThanOrEqualToBinaryOperator)
  | IsGreaterThanOrEqualTo(isGreaterThanOrEqualToBinaryOperator)
  | SetEqualTo(setEqualToBinaryOperator)

and argumentFunctionCallArgument =
  { id: string, label: option(string), expression: expression }

and placeholderFunctionCallArgument =
  { id: string }

and functionCallArgument =
  | Argument(argumentFunctionCallArgument)
  | Placeholder(placeholderFunctionCallArgument)

and binaryExpressionExpression =
  { left: expression, right: expression, op: binaryOperator, id: string }

and identifierExpressionExpression =
  { id: string, identifier: identifier }

and functionCallExpressionExpression =
  { id: string, expression: expression, arguments: list(functionCallArgument) }

and literalExpressionExpression =
  { id: string, literal: literal }

and memberExpressionExpression =
  { id: string, expression: expression, memberName: identifier }

and placeholderExpression =
  { id: string }

and expression =
  | BinaryExpression(binaryExpressionExpression)
  | IdentifierExpression(identifierExpressionExpression)
  | FunctionCallExpression(functionCallExpressionExpression)
  | LiteralExpression(literalExpressionExpression)
  | MemberExpression(memberExpressionExpression)
  | Placeholder(placeholderExpression)

and loopStatement =
  {
    pattern: pattern,
    expression: expression,
    block: list(statement),
    id: string
  }

and branchStatement =
  { id: string, condition: expression, block: list(statement) }

and declarationStatement =
  { id: string, content: declaration }

and expressionStatementStatement =
  { id: string, expression: expression }

and placeholderStatement =
  { id: string }

and statement =
  | Loop(loopStatement)
  | Branch(branchStatement)
  | Declaration(declarationStatement)
  | ExpressionStatement(expressionStatementStatement)
  | Placeholder(placeholderStatement)

and programProgram =
  { id: string, block: list(statement) }

and program =
  | Program(programProgram)

and syntaxNode =
  | Statement(statement)
  | Declaration(declaration)
  | Identifier(identifier)
  | Expression(expression)
  | Pattern(pattern)
  | BinaryOperator(binaryOperator)
  | Program(program)
  | FunctionParameter(functionParameter)
  | FunctionParameterDefaultValue(functionParameterDefaultValue)
  | TypeAnnotation(typeAnnotation)
  | Literal(literal)
  | TopLevelParameters(topLevelParameters)
  | EnumerationCase(enumerationCase)
  | GenericParameter(genericParameter)
  | TopLevelDeclarations(topLevelDeclarations)
  | Comment(comment)
  | FunctionCallArgument(functionCallArgument)

and parameterFunctionParameter =
  {
    id: string,
    externalName: option(string),
    localName: pattern,
    annotation: typeAnnotation,
    defaultValue: functionParameterDefaultValue,
    comment: option(comment)
  }

and placeholderFunctionParameter =
  { id: string }

and functionParameter =
  | Parameter(parameterFunctionParameter)
  | Placeholder(placeholderFunctionParameter)

and noneFunctionParameterDefaultValue =
  { id: string }

and valueFunctionParameterDefaultValue =
  { id: string, expression: expression }

and functionParameterDefaultValue =
  | None(noneFunctionParameterDefaultValue)
  | Value(valueFunctionParameterDefaultValue)

and typeIdentifierTypeAnnotation =
  { id: string, identifier: identifier, genericArguments: list(typeAnnotation) }

and functionTypeTypeAnnotation =
  {
    id: string,
    returnType: typeAnnotation,
    argumentTypes: list(typeAnnotation)
  }

and placeholderTypeAnnotation =
  { id: string }

and typeAnnotation =
  | TypeIdentifier(typeIdentifierTypeAnnotation)
  | FunctionType(functionTypeTypeAnnotation)
  | Placeholder(placeholderTypeAnnotation)

and noneLiteral =
  { id: string }

and booleanLiteral =
  { id: string, value: bool }

and numberLiteral =
  { id: string, value: float }

and stringLiteral =
  { id: string, value: string }

and colorLiteral =
  { id: string, value: string }

and arrayLiteral =
  { id: string, value: list(expression) }

and literal =
  | None(noneLiteral)
  | Boolean(booleanLiteral)
  | Number(numberLiteral)
  | String(stringLiteral)
  | Color(colorLiteral)
  | Array(arrayLiteral)

and topLevelParametersTopLevelParameters =
  { id: string, parameters: list(functionParameter) }

and topLevelParameters =
  | TopLevelParameters(topLevelParametersTopLevelParameters)

and parameterGenericParameter =
  { id: string, name: pattern }

and placeholderGenericParameter =
  { id: string }

and genericParameter =
  | Parameter(parameterGenericParameter)
  | Placeholder(placeholderGenericParameter)

and topLevelDeclarationsTopLevelDeclarations =
  { id: string, declarations: list(declaration) }

and topLevelDeclarations =
  | TopLevelDeclarations(topLevelDeclarationsTopLevelDeclarations)

and commentComment =
  { id: string, string: string }

and comment =
  | Comment(commentComment);

module Decode = {
  let rec list: 't.(Json.Decode.decoder('t), Js.Json.t) => list('t) = (
    decoderT,
    json: Js.Json.t
  ) => {
    let rec decoded = Json.Decode.list( decoderT, json );
    let rec createPairs = ( items ) => { switch (items) {
      | [] => Empty;
      | [ a ] => Next( a, Empty );
      | [ a, ...rest ] => Next( a, createPairs( rest ) );
      }; };
    createPairs( decoded );
  }

  and identifier: (Js.Json.t) => identifier = ( json: Js.Json.t ) => {
    Identifier(
      {
        id: Json.Decode.field( "id", Json.Decode.string, json ),
        string: Json.Decode.field( "string", Json.Decode.string, json ),
        isPlaceholder: Json.Decode.field(
          "isPlaceholder",
          Json.Decode.bool,
          json
        )
      }
    );
  }

  and declaration: (Js.Json.t) => declaration = ( json: Js.Json.t ) => {
    let rec case = Json.Decode.field( "type", Json.Decode.string, json );
    let rec data = Json.Decode.field( "data", ( x ) => { x; }, json );
    switch (case) {
    | "variable" =>
      Variable(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          name: Json.Decode.field( "name", pattern, data ),
          annotation: Json.Decode.optional(
            Json.Decode.field( "annotation", typeAnnotation ),
            data
          ),
          initializer_: Json.Decode.optional(
            Json.Decode.field( "initializer", expression ),
            data
          ),
          comment: Json.Decode.optional(
            Json.Decode.field( "comment", comment ),
            data
          )
        }
      );
    | "function" =>
      Function(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          name: Json.Decode.field( "name", pattern, data ),
          returnType: Json.Decode.field( "returnType", typeAnnotation, data ),
          genericParameters: Json.Decode.field(
            "genericParameters",
            list( genericParameter ),
            data
          ),
          parameters: Json.Decode.field(
            "parameters",
            list( functionParameter ),
            data
          ),
          block: Json.Decode.field( "block", list( statement ), data ),
          comment: Json.Decode.optional(
            Json.Decode.field( "comment", comment ),
            data
          )
        }
      );
    | "enumeration" =>
      Enumeration(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          name: Json.Decode.field( "name", pattern, data ),
          genericParameters: Json.Decode.field(
            "genericParameters",
            list( genericParameter ),
            data
          ),
          cases: Json.Decode.field( "cases", list( enumerationCase ), data ),
          comment: Json.Decode.optional(
            Json.Decode.field( "comment", comment ),
            data
          )
        }
      );
    | "namespace" =>
      Namespace(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          name: Json.Decode.field( "name", pattern, data ),
          declarations: Json.Decode.field(
            "declarations",
            list( declaration ),
            data
          )
        }
      );
    | "placeholder" =>
      Placeholder(
        { id: Json.Decode.field( "id", Json.Decode.string, data ) }
      );
    | "record" =>
      Record(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          name: Json.Decode.field( "name", pattern, data ),
          genericParameters: Json.Decode.field(
            "genericParameters",
            list( genericParameter ),
            data
          ),
          declarations: Json.Decode.field(
            "declarations",
            list( declaration ),
            data
          ),
          comment: Json.Decode.optional(
            Json.Decode.field( "comment", comment ),
            data
          )
        }
      );
    | "importDeclaration" =>
      ImportDeclaration(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          name: Json.Decode.field( "name", pattern, data )
        }
      );
    | _ =>
      Js.log( "Error decoding declaration" );
      raise( Not_found );
    };
  }

  and enumerationCase: (Js.Json.t) => enumerationCase = ( json: Js.Json.t ) => {
    let rec case = Json.Decode.field( "type", Json.Decode.string, json );
    let rec data = Json.Decode.field( "data", ( x ) => { x; }, json );
    switch (case) {
    | "placeholder" =>
      Placeholder(
        { id: Json.Decode.field( "id", Json.Decode.string, data ) }
      );
    | "enumerationCase" =>
      EnumerationCase(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          name: Json.Decode.field( "name", pattern, data ),
          associatedValueTypes: Json.Decode.field(
            "associatedValueTypes",
            list( typeAnnotation ),
            data
          ),
          comment: Json.Decode.optional(
            Json.Decode.field( "comment", comment ),
            data
          )
        }
      );
    | _ =>
      Js.log( "Error decoding enumerationCase" );
      raise( Not_found );
    };
  }

  and pattern: (Js.Json.t) => pattern = ( json: Js.Json.t ) => {
    Pattern(
      {
        id: Json.Decode.field( "id", Json.Decode.string, json ),
        name: Json.Decode.field( "name", Json.Decode.string, json )
      }
    );
  }

  and binaryOperator: (Js.Json.t) => binaryOperator = ( json: Js.Json.t ) => {
    let rec case = Json.Decode.field( "type", Json.Decode.string, json );
    let rec data = Json.Decode.field( "data", ( x ) => { x; }, json );
    switch (case) {
    | "isEqualTo" =>
      IsEqualTo( { id: Json.Decode.field( "id", Json.Decode.string, data ) } );
    | "isNotEqualTo" =>
      IsNotEqualTo(
        { id: Json.Decode.field( "id", Json.Decode.string, data ) }
      );
    | "isLessThan" =>
      IsLessThan( { id: Json.Decode.field( "id", Json.Decode.string, data ) } );
    | "isGreaterThan" =>
      IsGreaterThan(
        { id: Json.Decode.field( "id", Json.Decode.string, data ) }
      );
    | "isLessThanOrEqualTo" =>
      IsLessThanOrEqualTo(
        { id: Json.Decode.field( "id", Json.Decode.string, data ) }
      );
    | "isGreaterThanOrEqualTo" =>
      IsGreaterThanOrEqualTo(
        { id: Json.Decode.field( "id", Json.Decode.string, data ) }
      );
    | "setEqualTo" =>
      SetEqualTo( { id: Json.Decode.field( "id", Json.Decode.string, data ) } );
    | _ =>
      Js.log( "Error decoding binaryOperator" );
      raise( Not_found );
    };
  }

  and functionCallArgument: (Js.Json.t) => functionCallArgument = (
    json: Js.Json.t
  ) => {
    let rec case = Json.Decode.field( "type", Json.Decode.string, json );
    let rec data = Json.Decode.field( "data", ( x ) => { x; }, json );
    switch (case) {
    | "argument" =>
      Argument(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          label: Json.Decode.optional(
            Json.Decode.field( "label", Json.Decode.string ),
            data
          ),
          expression: Json.Decode.field( "expression", expression, data )
        }
      );
    | "placeholder" =>
      Placeholder(
        { id: Json.Decode.field( "id", Json.Decode.string, data ) }
      );
    | _ =>
      Js.log( "Error decoding functionCallArgument" );
      raise( Not_found );
    };
  }

  and expression: (Js.Json.t) => expression = ( json: Js.Json.t ) => {
    let rec case = Json.Decode.field( "type", Json.Decode.string, json );
    let rec data = Json.Decode.field( "data", ( x ) => { x; }, json );
    switch (case) {
    | "binaryExpression" =>
      BinaryExpression(
        {
          left: Json.Decode.field( "left", expression, data ),
          right: Json.Decode.field( "right", expression, data ),
          op: Json.Decode.field( "op", binaryOperator, data ),
          id: Json.Decode.field( "id", Json.Decode.string, data )
        }
      );
    | "identifierExpression" =>
      IdentifierExpression(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          identifier: Json.Decode.field( "identifier", identifier, data )
        }
      );
    | "functionCallExpression" =>
      FunctionCallExpression(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          expression: Json.Decode.field( "expression", expression, data ),
          arguments: Json.Decode.field(
            "arguments",
            list( functionCallArgument ),
            data
          )
        }
      );
    | "literalExpression" =>
      LiteralExpression(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          literal: Json.Decode.field( "literal", literal, data )
        }
      );
    | "memberExpression" =>
      MemberExpression(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          expression: Json.Decode.field( "expression", expression, data ),
          memberName: Json.Decode.field( "memberName", identifier, data )
        }
      );
    | "placeholder" =>
      Placeholder(
        { id: Json.Decode.field( "id", Json.Decode.string, data ) }
      );
    | _ =>
      Js.log( "Error decoding expression" );
      raise( Not_found );
    };
  }

  and statement: (Js.Json.t) => statement = ( json: Js.Json.t ) => {
    let rec case = Json.Decode.field( "type", Json.Decode.string, json );
    let rec data = Json.Decode.field( "data", ( x ) => { x; }, json );
    switch (case) {
    | "loop" =>
      Loop(
        {
          pattern: Json.Decode.field( "pattern", pattern, data ),
          expression: Json.Decode.field( "expression", expression, data ),
          block: Json.Decode.field( "block", list( statement ), data ),
          id: Json.Decode.field( "id", Json.Decode.string, data )
        }
      );
    | "branch" =>
      Branch(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          condition: Json.Decode.field( "condition", expression, data ),
          block: Json.Decode.field( "block", list( statement ), data )
        }
      );
    | "declaration" =>
      Declaration(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          content: Json.Decode.field( "content", declaration, data )
        }
      );
    | "expressionStatement" =>
      ExpressionStatement(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          expression: Json.Decode.field( "expression", expression, data )
        }
      );
    | "placeholder" =>
      Placeholder(
        { id: Json.Decode.field( "id", Json.Decode.string, data ) }
      );
    | _ =>
      Js.log( "Error decoding statement" );
      raise( Not_found );
    };
  }

  and program: (Js.Json.t) => program = ( json: Js.Json.t ) => {
    Program(
      {
        id: Json.Decode.field( "id", Json.Decode.string, json ),
        block: Json.Decode.field( "block", list( statement ), json )
      }
    );
  }

  and syntaxNode: (Js.Json.t) => syntaxNode = ( json: Js.Json.t ) => {
    let rec case = Json.Decode.field( "type", Json.Decode.string, json );
    let rec data = Json.Decode.field( "data", ( x ) => { x; }, json );
    switch (case) {
    | "statement" =>
      let rec decoded = statement( data );
      Statement( decoded );
    | "declaration" =>
      let rec decoded = declaration( data );
      Declaration( decoded );
    | "identifier" =>
      let rec decoded = identifier( data );
      Identifier( decoded );
    | "expression" =>
      let rec decoded = expression( data );
      Expression( decoded );
    | "pattern" =>
      let rec decoded = pattern( data );
      Pattern( decoded );
    | "binaryOperator" =>
      let rec decoded = binaryOperator( data );
      BinaryOperator( decoded );
    | "program" =>
      let rec decoded = program( data );
      Program( decoded );
    | "functionParameter" =>
      let rec decoded = functionParameter( data );
      FunctionParameter( decoded );
    | "functionParameterDefaultValue" =>
      let rec decoded = functionParameterDefaultValue( data );
      FunctionParameterDefaultValue( decoded );
    | "typeAnnotation" =>
      let rec decoded = typeAnnotation( data );
      TypeAnnotation( decoded );
    | "literal" =>
      let rec decoded = literal( data );
      Literal( decoded );
    | "topLevelParameters" =>
      let rec decoded = topLevelParameters( data );
      TopLevelParameters( decoded );
    | "enumerationCase" =>
      let rec decoded = enumerationCase( data );
      EnumerationCase( decoded );
    | "genericParameter" =>
      let rec decoded = genericParameter( data );
      GenericParameter( decoded );
    | "topLevelDeclarations" =>
      let rec decoded = topLevelDeclarations( data );
      TopLevelDeclarations( decoded );
    | "comment" =>
      let rec decoded = comment( data );
      Comment( decoded );
    | "functionCallArgument" =>
      let rec decoded = functionCallArgument( data );
      FunctionCallArgument( decoded );
    | _ =>
      Js.log( "Error decoding syntaxNode" );
      raise( Not_found );
    };
  }

  and functionParameter: (Js.Json.t) => functionParameter = (
    json: Js.Json.t
  ) => {
    let rec case = Json.Decode.field( "type", Json.Decode.string, json );
    let rec data = Json.Decode.field( "data", ( x ) => { x; }, json );
    switch (case) {
    | "parameter" =>
      Parameter(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          externalName: Json.Decode.optional(
            Json.Decode.field( "externalName", Json.Decode.string ),
            data
          ),
          localName: Json.Decode.field( "localName", pattern, data ),
          annotation: Json.Decode.field( "annotation", typeAnnotation, data ),
          defaultValue: Json.Decode.field(
            "defaultValue",
            functionParameterDefaultValue,
            data
          ),
          comment: Json.Decode.optional(
            Json.Decode.field( "comment", comment ),
            data
          )
        }
      );
    | "placeholder" =>
      Placeholder(
        { id: Json.Decode.field( "id", Json.Decode.string, data ) }
      );
    | _ =>
      Js.log( "Error decoding functionParameter" );
      raise( Not_found );
    };
  }

  and functionParameterDefaultValue: (
    Js.Json.t
  ) => functionParameterDefaultValue = ( json: Js.Json.t ) => {
    let rec case = Json.Decode.field( "type", Json.Decode.string, json );
    let rec data = Json.Decode.field( "data", ( x ) => { x; }, json );
    switch (case) {
    | "none" =>
      None( { id: Json.Decode.field( "id", Json.Decode.string, data ) } );
    | "value" =>
      Value(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          expression: Json.Decode.field( "expression", expression, data )
        }
      );
    | _ =>
      Js.log( "Error decoding functionParameterDefaultValue" );
      raise( Not_found );
    };
  }

  and typeAnnotation: (Js.Json.t) => typeAnnotation = ( json: Js.Json.t ) => {
    let rec case = Json.Decode.field( "type", Json.Decode.string, json );
    let rec data = Json.Decode.field( "data", ( x ) => { x; }, json );
    switch (case) {
    | "typeIdentifier" =>
      TypeIdentifier(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          identifier: Json.Decode.field( "identifier", identifier, data ),
          genericArguments: Json.Decode.field(
            "genericArguments",
            list( typeAnnotation ),
            data
          )
        }
      );
    | "functionType" =>
      FunctionType(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          returnType: Json.Decode.field( "returnType", typeAnnotation, data ),
          argumentTypes: Json.Decode.field(
            "argumentTypes",
            list( typeAnnotation ),
            data
          )
        }
      );
    | "placeholder" =>
      Placeholder(
        { id: Json.Decode.field( "id", Json.Decode.string, data ) }
      );
    | _ =>
      Js.log( "Error decoding typeAnnotation" );
      raise( Not_found );
    };
  }

  and literal: (Js.Json.t) => literal = ( json: Js.Json.t ) => {
    let rec case = Json.Decode.field( "type", Json.Decode.string, json );
    let rec data = Json.Decode.field( "data", ( x ) => { x; }, json );
    switch (case) {
    | "none" =>
      None( { id: Json.Decode.field( "id", Json.Decode.string, data ) } );
    | "boolean" =>
      Boolean(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          value: Json.Decode.field( "value", Json.Decode.bool, data )
        }
      );
    | "number" =>
      Number(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          value: Json.Decode.field( "value", Json.Decode.float, data )
        }
      );
    | "string" =>
      String(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          value: Json.Decode.field( "value", Json.Decode.string, data )
        }
      );
    | "color" =>
      Color(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          value: Json.Decode.field( "value", Json.Decode.string, data )
        }
      );
    | "array" =>
      Array(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          value: Json.Decode.field( "value", list( expression ), data )
        }
      );
    | _ =>
      Js.log( "Error decoding literal" );
      raise( Not_found );
    };
  }

  and topLevelParameters: (Js.Json.t) => topLevelParameters = (
    json: Js.Json.t
  ) => {
    TopLevelParameters(
      {
        id: Json.Decode.field( "id", Json.Decode.string, json ),
        parameters: Json.Decode.field(
          "parameters",
          list( functionParameter ),
          json
        )
      }
    );
  }

  and genericParameter: (Js.Json.t) => genericParameter = (
    json: Js.Json.t
  ) => {
    let rec case = Json.Decode.field( "type", Json.Decode.string, json );
    let rec data = Json.Decode.field( "data", ( x ) => { x; }, json );
    switch (case) {
    | "parameter" =>
      Parameter(
        {
          id: Json.Decode.field( "id", Json.Decode.string, data ),
          name: Json.Decode.field( "name", pattern, data )
        }
      );
    | "placeholder" =>
      Placeholder(
        { id: Json.Decode.field( "id", Json.Decode.string, data ) }
      );
    | _ =>
      Js.log( "Error decoding genericParameter" );
      raise( Not_found );
    };
  }

  and topLevelDeclarations: (Js.Json.t) => topLevelDeclarations = (
    json: Js.Json.t
  ) => {
    TopLevelDeclarations(
      {
        id: Json.Decode.field( "id", Json.Decode.string, json ),
        declarations: Json.Decode.field(
          "declarations",
          list( declaration ),
          json
        )
      }
    );
  }

  and comment: (Js.Json.t) => comment = ( json: Js.Json.t ) => {
    Comment(
      {
        id: Json.Decode.field( "id", Json.Decode.string, json ),
        string: Json.Decode.field( "string", Json.Decode.string, json )
      }
    );
  };
};
