type lGCSyntaxNode = LogicAst.syntaxNode;

let encodeLGCSyntaxNode = (lGCSyntaxNode): Js.Json.t =>
  Js.Json.string("problem encoding LGCSyntaxNode");

let decodeLGCSyntaxNode = LogicAst.Decode.syntaxNode;

/* LONA: KEEP ABOVE */

type textText = {value: string}

and text = textText

and imageImage = {
  alt: option(string),
  url: string,
}

and image = imageImage

and strongStrong = {children: Reason.List.t(inlineNode)}

and strong = strongStrong

and emphasisEmphasis = {children: Reason.List.t(inlineNode)}

and emphasis = emphasisEmphasis

and inlineCodeInlineCode = {value: string}

and inlineCode = inlineCodeInlineCode

and breakBreak = unit

and break = breakBreak

and linkLink = {
  children: Reason.List.t(inlineNode),
  url: string,
}

and link = linkLink

and paragraphParagraph = {children: Reason.List.t(inlineNode)}

and paragraph = paragraphParagraph

and headingHeading = {
  depth: Reason.Int.t,
  children: Reason.List.t(inlineNode),
}

and heading = headingHeading

and blockquoteBlockquote = {children: Reason.List.t(inlineNode)}

and blockquote = blockquoteBlockquote

and codeCode = {
  lang: option(string),
  value: string,
  parsed: option(lGCSyntaxNode),
}

and code = codeCode

and thematicBreakThematicBreak = unit

and thematicBreak = thematicBreakThematicBreak

and listList = {
  ordered: bool,
  children: Reason.List.t(listItemNode),
}

and list = listList

and listItemListItemNode = {children: Reason.List.t(blockNode)}

and listItemNode =
  | ListItem(listItemListItemNode)

and pagePage = {value: string}

and page = pagePage

and rootRoot = {children: Reason.List.t(blockNode)}

and root = rootRoot

and blockNode =
  | Image(image)
  | Paragraph(paragraph)
  | Heading(heading)
  | Code(code)
  | ThematicBreak(thematicBreak)
  | Blockquote(blockquote)
  | List(list)
  | Page(page)

and inlineNode =
  | Text(text)
  | Strong(strong)
  | Emphasis(emphasis)
  | InlineCode(inlineCode)
  | Link(link)
  | Break(break);

module Decode = {
  let rec decodeText: Js.Json.t => text =
    (json: Js.Json.t) => {
      {value: Json.Decode.field("value", Json.Decode.string, json)};
    }

  and decodeImage: Js.Json.t => image =
    (json: Js.Json.t) => {
      {
        alt:
          Json.Decode.optional(
            Json.Decode.field("alt", Json.Decode.string),
            json,
          ),
        url: Json.Decode.field("url", Json.Decode.string, json),
      };
    }

  and decodeStrong: Js.Json.t => strong =
    (json: Js.Json.t) => {
      {
        children:
          Json.Decode.field(
            "children",
            Reason.List.decode(decodeInlineNode),
            json,
          ),
      };
    }

  and decodeEmphasis: Js.Json.t => emphasis =
    (json: Js.Json.t) => {
      {
        children:
          Json.Decode.field(
            "children",
            Reason.List.decode(decodeInlineNode),
            json,
          ),
      };
    }

  and decodeInlineCode: Js.Json.t => inlineCode =
    (json: Js.Json.t) => {
      {value: Json.Decode.field("value", Json.Decode.string, json)};
    }

  and decodeBreak: Js.Json.t => break =
    (json: Js.Json.t) => {
      ();
    }

  and decodeLink: Js.Json.t => link =
    (json: Js.Json.t) => {
      {
        children:
          Json.Decode.field(
            "children",
            Reason.List.decode(decodeInlineNode),
            json,
          ),
        url: Json.Decode.field("url", Json.Decode.string, json),
      };
    }

  and decodeParagraph: Js.Json.t => paragraph =
    (json: Js.Json.t) => {
      {
        children:
          Json.Decode.field(
            "children",
            Reason.List.decode(decodeInlineNode),
            json,
          ),
      };
    }

  and decodeHeading: Js.Json.t => heading =
    (json: Js.Json.t) => {
      {
        depth: Json.Decode.field("depth", Reason.Int.decode, json),
        children:
          Json.Decode.field(
            "children",
            Reason.List.decode(decodeInlineNode),
            json,
          ),
      };
    }

  and decodeBlockquote: Js.Json.t => blockquote =
    (json: Js.Json.t) => {
      {
        children:
          Json.Decode.field(
            "children",
            Reason.List.decode(decodeInlineNode),
            json,
          ),
      };
    }

  and decodeCode: Js.Json.t => code =
    (json: Js.Json.t) => {
      {
        lang:
          Json.Decode.optional(
            Json.Decode.field("lang", Json.Decode.string),
            json,
          ),
        value: Json.Decode.field("value", Json.Decode.string, json),
        parsed:
          Json.Decode.optional(
            Json.Decode.field("parsed", decodeLGCSyntaxNode),
            json,
          ),
      };
    }

  and decodeThematicBreak: Js.Json.t => thematicBreak =
    (json: Js.Json.t) => {
      ();
    }

  and decodeList: Js.Json.t => list =
    (json: Js.Json.t) => {
      {
        ordered: Json.Decode.field("ordered", Json.Decode.bool, json),
        children:
          Json.Decode.field(
            "children",
            Reason.List.decode(decodeListItemNode),
            json,
          ),
      };
    }

  and decodeListItemNode: Js.Json.t => listItemNode =
    (json: Js.Json.t) => {
      let rec case = Json.Decode.field("type", Json.Decode.string, json);
      let rec data = Json.Decode.field("data", x => x, json);
      switch (case) {
      | "listItem" =>
        ListItem({
          children:
            Json.Decode.field(
              "children",
              Reason.List.decode(decodeBlockNode),
              data,
            ),
        })
      | _ =>
        Js.log("Error decoding listItemNode");
        raise(Not_found);
      };
    }

  and decodePage: Js.Json.t => page =
    (json: Js.Json.t) => {
      {value: Json.Decode.field("value", Json.Decode.string, json)};
    }

  and decodeRoot: Js.Json.t => root =
    (json: Js.Json.t) => {
      {
        children:
          Json.Decode.field(
            "children",
            Reason.List.decode(decodeBlockNode),
            json,
          ),
      };
    }

  and decodeBlockNode: Js.Json.t => blockNode =
    (json: Js.Json.t) => {
      let rec case = Json.Decode.field("type", Json.Decode.string, json);
      let rec data = Json.Decode.field("data", x => x, json);
      switch (case) {
      | "image" =>
        let rec decoded = decodeImage(data);
        Image(decoded);
      | "paragraph" =>
        let rec decoded = decodeParagraph(data);
        Paragraph(decoded);
      | "heading" =>
        let rec decoded = decodeHeading(data);
        Heading(decoded);
      | "code" =>
        let rec decoded = decodeCode(data);
        Code(decoded);
      | "thematicBreak" =>
        let rec decoded = decodeThematicBreak(data);
        ThematicBreak(decoded);
      | "blockquote" =>
        let rec decoded = decodeBlockquote(data);
        Blockquote(decoded);
      | "list" =>
        let rec decoded = decodeList(data);
        List(decoded);
      | "page" =>
        let rec decoded = decodePage(data);
        Page(decoded);
      | _ =>
        Js.log("Error decoding blockNode");
        raise(Not_found);
      };
    }

  and decodeInlineNode: Js.Json.t => inlineNode =
    (json: Js.Json.t) => {
      let rec case = Json.Decode.field("type", Json.Decode.string, json);
      let rec data = Json.Decode.field("data", x => x, json);
      switch (case) {
      | "text" =>
        let rec decoded = decodeText(data);
        Text(decoded);
      | "strong" =>
        let rec decoded = decodeStrong(data);
        Strong(decoded);
      | "emphasis" =>
        let rec decoded = decodeEmphasis(data);
        Emphasis(decoded);
      | "inlineCode" =>
        let rec decoded = decodeInlineCode(data);
        InlineCode(decoded);
      | "link" =>
        let rec decoded = decodeLink(data);
        Link(decoded);
      | "break" =>
        let rec decoded = decodeBreak(data);
        Break(decoded);
      | _ =>
        Js.log("Error decoding inlineNode");
        raise(Not_found);
      };
    };
};

module Encode = {
  let rec encodeText: text => Js.Json.t =
    (value: text) => {
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [("value", Json.Encode.string(value.value))],
        ),
      );
    }

  and encodeImage: image => Js.Json.t =
    (value: image) => {
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            ("alt", Json.Encode.nullable(Json.Encode.string, value.alt)),
            ("url", Json.Encode.string(value.url)),
          ],
        ),
      );
    }

  and encodeStrong: strong => Js.Json.t =
    (value: strong) => {
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            (
              "children",
              Reason.List.encode(encodeInlineNode, value.children),
            ),
          ],
        ),
      );
    }

  and encodeEmphasis: emphasis => Js.Json.t =
    (value: emphasis) => {
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            (
              "children",
              Reason.List.encode(encodeInlineNode, value.children),
            ),
          ],
        ),
      );
    }

  and encodeInlineCode: inlineCode => Js.Json.t =
    (value: inlineCode) => {
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [("value", Json.Encode.string(value.value))],
        ),
      );
    }

  and encodeBreak: break => Js.Json.t =
    (value: break) => {
      Json.Encode.object_(
        List.filter(((_, json)) => json != Js.Json.null, []),
      );
    }

  and encodeLink: link => Js.Json.t =
    (value: link) => {
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            (
              "children",
              Reason.List.encode(encodeInlineNode, value.children),
            ),
            ("url", Json.Encode.string(value.url)),
          ],
        ),
      );
    }

  and encodeParagraph: paragraph => Js.Json.t =
    (value: paragraph) => {
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            (
              "children",
              Reason.List.encode(encodeInlineNode, value.children),
            ),
          ],
        ),
      );
    }

  and encodeHeading: heading => Js.Json.t =
    (value: heading) => {
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            ("depth", Reason.Int.encode(value.depth)),
            (
              "children",
              Reason.List.encode(encodeInlineNode, value.children),
            ),
          ],
        ),
      );
    }

  and encodeBlockquote: blockquote => Js.Json.t =
    (value: blockquote) => {
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            (
              "children",
              Reason.List.encode(encodeInlineNode, value.children),
            ),
          ],
        ),
      );
    }

  and encodeCode: code => Js.Json.t =
    (value: code) => {
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            ("lang", Json.Encode.nullable(Json.Encode.string, value.lang)),
            ("value", Json.Encode.string(value.value)),
            (
              "parsed",
              Json.Encode.nullable(encodeLGCSyntaxNode, value.parsed),
            ),
          ],
        ),
      );
    }

  and encodeThematicBreak: thematicBreak => Js.Json.t =
    (value: thematicBreak) => {
      Json.Encode.object_(
        List.filter(((_, json)) => json != Js.Json.null, []),
      );
    }

  and encodeList: list => Js.Json.t =
    (value: list) => {
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            ("ordered", Json.Encode.bool(value.ordered)),
            (
              "children",
              Reason.List.encode(encodeListItemNode, value.children),
            ),
          ],
        ),
      );
    }

  and encodeListItemNode: listItemNode => Js.Json.t =
    (value: listItemNode) => {
      switch (value) {
      | ListItem(value) =>
        let rec case = Json.Encode.string("listItem");
        let rec data =
          Json.Encode.object_(
            List.filter(
              ((_, json)) => json != Js.Json.null,
              [
                (
                  "children",
                  Reason.List.encode(encodeBlockNode, value.children),
                ),
              ],
            ),
          );
        Json.Encode.object_([("type", case), ("data", data)]);
      };
    }

  and encodePage: page => Js.Json.t =
    (value: page) => {
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [("value", Json.Encode.string(value.value))],
        ),
      );
    }

  and encodeRoot: root => Js.Json.t =
    (value: root) => {
      Json.Encode.object_(
        List.filter(
          ((_, json)) => json != Js.Json.null,
          [
            ("children", Reason.List.encode(encodeBlockNode, value.children)),
          ],
        ),
      );
    }

  and encodeBlockNode: blockNode => Js.Json.t =
    (value: blockNode) => {
      switch (value) {
      | Image(value0) =>
        let rec case = Json.Encode.string("image");
        let rec encoded = encodeImage(value0);
        Json.Encode.object_([("type", case), ("data", encoded)]);
      | Paragraph(value0) =>
        let rec case = Json.Encode.string("paragraph");
        let rec encoded = encodeParagraph(value0);
        Json.Encode.object_([("type", case), ("data", encoded)]);
      | Heading(value0) =>
        let rec case = Json.Encode.string("heading");
        let rec encoded = encodeHeading(value0);
        Json.Encode.object_([("type", case), ("data", encoded)]);
      | Code(value0) =>
        let rec case = Json.Encode.string("code");
        let rec encoded = encodeCode(value0);
        Json.Encode.object_([("type", case), ("data", encoded)]);
      | ThematicBreak(value0) =>
        let rec case = Json.Encode.string("thematicBreak");
        let rec encoded = encodeThematicBreak(value0);
        Json.Encode.object_([("type", case), ("data", encoded)]);
      | Blockquote(value0) =>
        let rec case = Json.Encode.string("blockquote");
        let rec encoded = encodeBlockquote(value0);
        Json.Encode.object_([("type", case), ("data", encoded)]);
      | List(value0) =>
        let rec case = Json.Encode.string("list");
        let rec encoded = encodeList(value0);
        Json.Encode.object_([("type", case), ("data", encoded)]);
      | Page(value0) =>
        let rec case = Json.Encode.string("page");
        let rec encoded = encodePage(value0);
        Json.Encode.object_([("type", case), ("data", encoded)]);
      };
    }

  and encodeInlineNode: inlineNode => Js.Json.t =
    (value: inlineNode) => {
      switch (value) {
      | Text(value0) =>
        let rec case = Json.Encode.string("text");
        let rec encoded = encodeText(value0);
        Json.Encode.object_([("type", case), ("data", encoded)]);
      | Strong(value0) =>
        let rec case = Json.Encode.string("strong");
        let rec encoded = encodeStrong(value0);
        Json.Encode.object_([("type", case), ("data", encoded)]);
      | Emphasis(value0) =>
        let rec case = Json.Encode.string("emphasis");
        let rec encoded = encodeEmphasis(value0);
        Json.Encode.object_([("type", case), ("data", encoded)]);
      | InlineCode(value0) =>
        let rec case = Json.Encode.string("inlineCode");
        let rec encoded = encodeInlineCode(value0);
        Json.Encode.object_([("type", case), ("data", encoded)]);
      | Link(value0) =>
        let rec case = Json.Encode.string("link");
        let rec encoded = encodeLink(value0);
        Json.Encode.object_([("type", case), ("data", encoded)]);
      | Break(value0) =>
        let rec case = Json.Encode.string("break");
        let rec encoded = encodeBreak(value0);
        Json.Encode.object_([("type", case), ("data", encoded)]);
      };
    };
};