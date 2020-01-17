// Project: https://github.com/syntax-tree/mdast
// Project: https://github.com/mdx-js/specification#mdxast
// Definitions:

import * as LogicAST from './logic-ast'

export type AlignType = 'left' | 'right' | 'center' | null
export type ReferenceType = 'shortcut' | 'collapsed' | 'full'

export interface Parent {
  type: string
  data: {
    children: Content[]
  }
}

export interface Literal {
  type: string
  data: {
    value: string
  }
}

export interface Root extends Parent {
  type: 'root'
}

export interface Paragraph extends Parent {
  type: 'paragraph'
  data: {
    children: PhrasingContent[]
  }
}

export interface Heading extends Parent {
  type: 'heading'
  data: {
    depth: 1 | 2 | 3 | 4 | 5 | 6 | number
    children: PhrasingContent[]
  }
}

export interface ThematicBreak {
  type: 'thematicBreak'
  data: {}
}

export interface Blockquote extends Parent {
  type: 'blockquote'
  data: {
    children: BlockContent[]
  }
}

export interface List extends Parent {
  type: 'list'
  data: {
    ordered?: boolean
    start?: number
    spread?: boolean
    children: ListContent[]
  }
}

export interface ListItem extends Parent {
  type: 'listItem'
  data: {
    checked?: boolean
    spread?: boolean
    children: BlockContent[]
  }
}

export interface Table extends Parent {
  type: 'table'
  data: {
    align?: AlignType[]
    children: TableContent[]
  }
}

export interface TableRow extends Parent {
  type: 'tableRow'
  data: { children: RowContent[] }
}

export interface TableCell extends Parent {
  type: 'tableCell'
  data: { children: PhrasingContent[] }
}

export interface HTML extends Literal {
  type: 'html'
}

export interface Code extends Literal {
  type: 'code'
  data: {
    lang?: string
    meta?: string
    value: string
    parsed?: LogicAST.TopLevelDeclarations
  }
}

export interface LonaTokens extends Code {
  type: 'code'
  data: {
    lang: 'tokens'
    meta?: string
    value: string
    parsed: LogicAST.TopLevelDeclarations
  }
}

export interface YAML extends Literal {
  type: 'yaml'
}

export interface Definition {
  type: 'definition'
  data: {
    identifier: string
    label?: string
    referenceType: ReferenceType
    url: string
    title?: string
  }
}

export interface FootnoteDefinition extends Parent {
  type: 'footnoteDefinition'
  data: {
    identifier: string
    label?: string
    children: BlockContent[]
  }
}

export interface Text extends Literal {
  type: 'text'
}

export interface Emphasis extends Parent {
  type: 'emphasis'
  data: {
    children: PhrasingContent[]
  }
}

export interface Strong extends Parent {
  type: 'strong'
  data: { children: PhrasingContent[] }
}

export interface Delete extends Parent {
  type: 'delete'
  data: { children: PhrasingContent[] }
}

export interface InlineCode extends Literal {
  type: 'inlineCode'
}

export interface Break {
  type: 'break'
  data: {}
}

export interface Link extends Parent {
  type: 'link'
  data: {
    url: string
    title?: string
    children: StaticPhrasingContent[]
  }
}

export interface Image {
  type: 'image'
  data: {
    url: string
    title?: string
    alt?: string
  }
}

export interface LinkReference extends Parent {
  type: 'linkReference'
  data: {
    identifier: string
    label?: string
    referenceType: ReferenceType
    children: StaticPhrasingContent[]
  }
}

export interface ImageReference {
  type: 'imageReference'
  data: {
    identifier: string
    label?: string
    referenceType: ReferenceType
    alt?: string
  }
}

export interface Footnote extends Parent {
  type: 'footnote'
  data: { children: PhrasingContent[] }
}

export interface FootnoteReference {
  type: 'footnoteReference'
  data: {
    identifier: string
    label?: string
  }
}

export interface JSXImport extends Literal {
  type: 'import'
}

export interface JSXExport extends Literal {
  type: 'export'
}

export interface JSXValue extends Literal {
  type: 'jsx'
}

export interface Page extends Literal {
  type: 'page'
  data: {
    url: string
    value: string
  }
}

export type JSX = JSXImport | JSXExport | JSXValue

/**
  Each node in mdast falls into one or more categories of Content that group nodes with similar characteristics together.
  */
export type Content =
  | TopLevelContent
  | ListContent
  | TableContent
  | RowContent
  | PhrasingContent
  | JSX

/**
  Top-level content represent the sections of document (block content), and metadata such as frontmatter and definitions.
  */
export type TopLevelContent =
  | BlockContent
  | FrontmatterContent
  | DefinitionContent
  | JSX

/**
  Block content represent the sections of document.
  */
export type BlockContent =
  | Paragraph
  | Heading
  | ThematicBreak
  | Blockquote
  | List
  | Table
  | HTML
  | Code
  | JSX
  | Page

/**
  Frontmatter content represent out-of-band information about the document.

  If frontmatter is present, it must be limited to one node in the tree, and can only exist as a head.
  */
export type FrontmatterContent = YAML

/**
  Definition content represents out-of-band information that typically affects the document through Association.
  */
export type DefinitionContent = Definition | FootnoteDefinition

/**
  List content represent the items in a list.
*/
export type ListContent = ListItem

/**
  Table content represent the rows in a table.
  */
export type TableContent = TableRow

/**
  Row content represent the cells in a row.
  */
export type RowContent = TableCell

/**
  Phrasing content represent the text in a document, and its markup.
  */
export type PhrasingContent = StaticPhrasingContent | Link | LinkReference

/**
  StaticPhrasing content represent the text in a document, and its markup, that is not intended for user interaction.
  */
export type StaticPhrasingContent =
  | Text
  | Emphasis
  | Strong
  | Delete
  | HTML
  | InlineCode
  | Break
  | Image
  | ImageReference
  | Footnote
  | FootnoteReference
