open JavaScriptAst;

let render =
    (options: JavaScriptOptions.options, colors, textStyles: TextStyle.file) => {
  let buildStyleNodeForFramework =
    options.framework
    |> (
      (framework, value: Types.lonaValue) =>
        switch (framework) {
        | JavaScriptOptions.ReactDOM =>
          Literal(
            LonaValue.string(
              value.data |> ReactDomTranslators.convertUnitlessStyle,
            ),
          )
        | _ => Literal(value)
        }
    );
  let unwrapOptional = (f, a) =>
    switch (a) {
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
               data: Js.Json.string(value),
             };
             Property({
               key: Identifier(["fontFamily"]),
               value: Literal(lonaValue),
             });
           }),
        lookup(style => style.fontWeight)
        |> unwrapOptional(value => {
             let lonaValue: Types.lonaValue = {
               ltype: Types.stringType,
               data: Js.Json.string(value),
             };
             Property({
               key: Identifier(["fontWeight"]),
               value: Literal(lonaValue),
             });
           }),
        lookup(style => style.fontSize)
        |> unwrapOptional(value => {
             let lonaValue: Types.lonaValue = {
               ltype: Types.numberType,
               data: Js.Json.number(value),
             };
             Property({
               key: Identifier(["fontSize"]),
               value: lonaValue |> buildStyleNodeForFramework,
             });
           }),
        lookup(style => style.lineHeight)
        |> unwrapOptional(value => {
             let lonaValue: Types.lonaValue = {
               ltype: Types.numberType,
               data: Js.Json.number(value),
             };
             Property({
               key: Identifier(["lineHeight"]),
               value: lonaValue |> buildStyleNodeForFramework,
             });
           }),
        lookup(style => style.letterSpacing)
        |> unwrapOptional(value => {
             let lonaValue: Types.lonaValue = {
               ltype: Types.numberType,
               data: Js.Json.number(value),
             };
             Property({
               key: Identifier(["letterSpacing"]),
               value: lonaValue |> buildStyleNodeForFramework,
             });
           }),
        lookup(style => style.color)
        |> unwrapOptional(value => {
             let value =
               switch (Color.find(colors, value)) {
               | Some(color) => Identifier(["colors", color.id])
               | None =>
                 let lonaValue: Types.lonaValue = {
                   ltype: Types.colorType,
                   data: Js.Json.string(value),
                 };
                 Literal(lonaValue);
               };
             Property({key: Identifier(["color"]), value});
           }),
      ]
      |> List.concat;
    Property({
      key: Identifier([textStyle.id |> JavaScriptFormat.styleVariableName]),
      value: ObjectLiteral(variables),
    });
  };
  let doc =
    Program([
      ImportDeclaration({
        source: "./colors",
        specifiers: [ImportDefaultSpecifier("colors")],
      }),
      Empty,
      ExportDefaultDeclaration(
        ObjectLiteral(textStyles.styles |> List.map(propertyDoc)),
      ),
      Empty,
    ]);
  JavaScriptRender.toString(doc);
};