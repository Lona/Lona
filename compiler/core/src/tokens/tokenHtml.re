open Operators;
open Monad;

let tokenNameElement = (kind, content): XmlAst.element => {
  tag: "span",
  attributes: [
    {name: "class", value: "lona-token-name lona-token-name-" ++ kind},
  ],
  content,
};

let tokenValueElement = (kind, content): XmlAst.element => {
  tag: "span",
  attributes: [
    {name: "class", value: "lona-token-value lona-token-value-" ++ kind},
  ],
  content,
};

let tokenContainerElement = (kind, content): XmlAst.element => {
  tag: "div",
  attributes: [{name: "class", value: "lona-token lona-token-" ++ kind}],
  content,
};

let tokenDetailsElement = (kind, content): XmlAst.element => {
  tag: "div",
  attributes: [
    {name: "class", value: "lona-token-details lona-token-details-" ++ kind},
  ],
  content,
};

let convert = (token: TokenTypes.token): string => {
  let makeDetails = (kind, tokenName, tokenValue) =>
    tokenDetailsElement(
      kind,
      [
        Element(tokenNameElement(kind, [tokenName])),
        Element(tokenValueElement(kind, [tokenValue])),
      ],
    );

  let tokenName =
    XmlAst.CharData(token.qualifiedName |> Format.joinWith("."));

  let xml =
    switch (token.value) {
    | Color({css}) =>
      let kind = "color";

      tokenContainerElement(
        kind,
        [
          Element({
            tag: "div",
            attributes: [
              {
                name: "class",
                value: "lona-token-preview lona-token-preview-color",
              },
              {name: "data-color", value: css},
            ],
            content: [],
          }),
          Element(makeDetails(kind, tokenName, XmlAst.CharData(css))),
        ],
      );
    | Shadow({x, y, blur, radius, color: {css}}) =>
      let kind = "color";
      let dataPairs = [
        ("x", x |> Format.floatToString),
        ("y", y |> Format.floatToString),
        ("blur", blur |> Format.floatToString),
        ("radius", radius |> Format.floatToString),
        ("color", css),
      ];
      let tokenValue =
        Format.floatToString(x)
        ++ "px "
        ++ Format.floatToString(y)
        ++ "px "
        ++ Format.floatToString(blur)
        ++ "px "
        ++ Format.floatToString(radius)
        ++ "px "
        ++ css;

      tokenContainerElement(
        kind,
        [
          Element({
            tag: "div",
            attributes:
              [
                {
                  XmlAst.name: "class",
                  value: "lona-token-preview lona-token-preview-color",
                },
              ]
              @ (
                dataPairs
                |> List.map(((name, value)) =>
                     {XmlAst.name: "data-" ++ name, value}
                   )
              ),
            content: [],
          }),
          Element(
            makeDetails(kind, tokenName, XmlAst.CharData(tokenValue)),
          ),
        ],
      );
    | TextStyle({
        fontFamily,
        fontWeight,
        fontSize,
        lineHeight,
        letterSpacing,
        color,
      }) =>
      let kind = "textStyle";
      let dataPairs =
        [
          ("fontFamily", fontFamily),
          (
            "fontWeight",
            fontWeight
            |> TokenTypes.Encode.encodeFontWeight
            |> Js.Json.decodeString,
          ),
          ("fontSize", fontSize |> map(Format.floatToString)),
          ("lineHeight", lineHeight |> map(Format.floatToString)),
          ("letterSpacing", letterSpacing |> map(Format.floatToString)),
          (
            "color",
            color |> map((color: TokenTypes.colorValue) => color.css),
          ),
        ]
        |> Sequence.compactMap(((key, value)) =>
             switch (value) {
             | Some(value) => Some((key, value))
             | None => None
             }
           );

      tokenContainerElement(
        kind,
        [
          Element({
            tag: "div",
            attributes:
              [
                {
                  XmlAst.name: "class",
                  value: "lona-token-preview lona-token-preview-color",
                },
              ]
              @ (
                dataPairs
                |> List.map(((name, value)) =>
                     {XmlAst.name: "data-" ++ name, value}
                   )
              ),
            content: [],
          }),
          Element(makeDetails(kind, tokenName, tokenName)),
        ],
      );
    };

  xml |> XmlRender.renderElement |> XmlRender.toString;
};