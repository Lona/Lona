open JavaScriptAst;

let render = (textStyles: TextStyle.file) => {
  let unwrapOptional = (f, a) =>
    switch a {
    | Some(value) => [f(value)]
    | None => []
    };
  let propertyDoc = (textStyle: TextStyle.t) => {
    let lookup = f => TextStyle.lookup(textStyles.styles, textStyle, f);
    let variables =
      [
        lookup(style => style.fontFamily)
        |> unwrapOptional(value => {
             let lonaValue: Types.lonaValue = {
               ltype: Types.stringType,
               data: Js.Json.string(value)
             };
             Property({
               "key": Identifier(["family"]),
               "value": Literal(lonaValue)
             });
           }),
        lookup(style => style.fontWeight)
        |> unwrapOptional(value => {
             let lonaValue: Types.lonaValue = {
               ltype: Types.stringType,
               data: Js.Json.string(value)
             };
             Property({
               "key": Identifier(["fontWeight"]),
               "value": Literal(lonaValue)
             });
           }),
        lookup(style => style.fontSize)
        |> unwrapOptional(value => {
             let lonaValue: Types.lonaValue = {
               ltype: Types.numberType,
               data: Js.Json.number(value)
             };
             Property({
               "key": Identifier(["fontSize"]),
               "value": Literal(lonaValue)
             });
           }),
        lookup(style => style.lineHeight)
        |> unwrapOptional(value => {
             let lonaValue: Types.lonaValue = {
               ltype: Types.numberType,
               data: Js.Json.number(value)
             };
             Property({
               "key": Identifier(["lineHeight"]),
               "value": Literal(lonaValue)
             });
           }),
        lookup(style => style.letterSpacing)
        |> unwrapOptional(value => {
             let lonaValue: Types.lonaValue = {
               ltype: Types.numberType,
               data: Js.Json.number(value)
             };
             Property({
               "key": Identifier(["letterSpacing"]),
               "value": Literal(lonaValue)
             });
           }),
        lookup(style => style.color)
        |> unwrapOptional(value => {
             let lonaValue: Types.lonaValue = {
               ltype: Types.colorType,
               data: Js.Json.string(value)
             };
             Property({
               "key": Identifier(["color"]),
               "value": Literal(lonaValue)
             });
           })
      ]
      |> List.concat;
    Property({
      "key": Identifier([textStyle.id]),
      "value": ObjectLiteral(variables)
    });
  };
  let doc =
    Program([
      ExportDefaultDeclaration(
        ObjectLiteral(textStyles.styles |> List.map(propertyDoc))
      ),
      Empty
    ]);
  JavaScriptRender.toString(doc);
};