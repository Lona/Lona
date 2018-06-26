open JavaScriptAst;

let makeRule = (key, level, xs) =>
  Property({
    "key": StringLiteral(key),
    "value": ArrayLiteral([StringLiteral(level), xs]),
  });

let maybeMap = fn =>
  fun
  | Some(v) => Some(fn(v))
  | None => None;

let optToStringLiteral =
  fun
  | Some(v) => StringLiteral(v)
  | None => Empty;

let makeColorRules = colors => {
  let grabHex = (color: Color.t) =>
    Property({
      "key": Identifier([color.name]),
      "value": Literal(LonaValue.string(color.value)),
    });

  makeRule(
    "colorPalette",
    "Error",
    ObjectLiteral(colors |> List.map(grabHex)),
  );
};

let makeFontSizes = textStyles => {
  let grabSizes = (text: TextStyle.t) =>
    text.fontSize |> maybeMap(int_of_float);

  makeRule(
    "fontSize",
    "Error",
    ArrayLiteral(
      textStyles
      |> List.map(grabSizes)
      |> List.sort_uniq(Pervasives.compare)
      |> List.map(maybeMap(string_of_int))
      |> List.map(optToStringLiteral),
    ),
  );
};

let makeFontFamilies = (textStyles: list(TextStyle.t)) =>
  makeRule(
    "fontFamily",
    "Error",
    ArrayLiteral(
      textStyles
      |> List.map((t: TextStyle.t) => t.fontFamily)
      |> List.sort_uniq(Pervasives.compare)
      |> List.map(optToStringLiteral),
    ),
  );

/* let makeShadows = (shadows: list(Shadow.t)) => {
     let constructShadow = (t: Shadow.t) =>
       ObjectLiteral([
         Property({
           "key": Identifier(["color"]),
           "value": Literal(LonaValue.string(t.color)),
         }),
       ]);

     makeRule(
       "shadow",
       "Error",
       ArrayLiteral(shadows |> List.map(constructShadow)),
     );
   }; */

let render = (~colors, ~textStyles /*, ~shadows */) => {
  let doc =
    Program([
      ObjectLiteral([
        Property({
          "key": Identifier(["rules"]),
          "value":
            ObjectLiteral([
              makeColorRules(colors),
              makeFontSizes(textStyles),
              makeFontFamilies(textStyles),
              /* makeShadows(shadows), */
            ]),
        }),
      ]),
    ]);

  JavaScriptRender.toString(doc);
};