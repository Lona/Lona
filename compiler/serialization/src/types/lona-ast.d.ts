// Project: https://github.com/syntax-tree/mdast
// Project: https://github.com/mdx-js/specification#mdxast
// Definitions:

declare module 'lona-ast' {
  export namespace AST {
    type AlignType = 'left' | 'right' | 'center' | null
    type ReferenceType = 'shortcut' | 'collapsed' | 'full'

    interface Parent {
      type: string
      data: {
        children: Content[]
      }
    }

    interface Literal {
      type: string
      data: {
        value: string
      }
    }

    interface Root extends Parent {
      type: 'root'
    }

    interface Paragraph extends Parent {
      type: 'paragraph'
      data: {
        children: PhrasingContent[]
      }
    }

    interface Heading extends Parent {
      type: 'heading'
      data: {
        depth: 1 | 2 | 3 | 4 | 5 | 6 | number
        children: PhrasingContent[]
      }
    }

    interface ThematicBreak {
      type: 'thematicBreak'
      data: {}
    }

    interface Blockquote extends Parent {
      type: 'blockquote'
      data: {
        children: BlockContent[]
      }
    }

    interface List extends Parent {
      type: 'list'
      data: {
        ordered?: boolean
        start?: number
        spread?: boolean
        children: ListContent[]
      }
    }

    interface ListItem extends Parent {
      type: 'listItem'
      data: {
        checked?: boolean
        spread?: boolean
        children: BlockContent[]
      }
    }

    interface Table extends Parent {
      type: 'table'
      data: {
        align?: AlignType[]
        children: TableContent[]
      }
    }

    interface TableRow extends Parent {
      type: 'tableRow'
      data: { children: RowContent[] }
    }

    interface TableCell extends Parent {
      type: 'tableCell'
      data: { children: PhrasingContent[] }
    }

    interface HTML extends Literal {
      type: 'html'
    }

    interface Code extends Literal {
      type: 'code'
      data: {
        lang?: string
        meta?: string
        value: string
        parsed?: Object
      }
    }

    interface LonaTokens extends Code {
      type: 'code'
      data: {
        lang: 'tokens'
        meta?: string
        value: string
        // TODO:
        parsed: any
      }
    }

    interface YAML extends Literal {
      type: 'yaml'
    }

    interface Definition {
      type: 'definition'
      data: {
        identifier: string
        label?: string
        referenceType: ReferenceType
        url: string
        title?: string
      }
    }

    interface FootnoteDefinition extends Parent {
      type: 'footnoteDefinition'
      data: {
        identifier: string
        label?: string
        children: BlockContent[]
      }
    }

    interface Text extends Literal {
      type: 'text'
    }

    interface Emphasis extends Parent {
      type: 'emphasis'
      data: {
        children: PhrasingContent[]
      }
    }

    interface Strong extends Parent {
      type: 'strong'
      data: { children: PhrasingContent[] }
    }

    interface Delete extends Parent {
      type: 'delete'
      data: { children: PhrasingContent[] }
    }

    interface InlineCode extends Literal {
      type: 'inlineCode'
    }

    interface Break {
      type: 'break'
      data: {}
    }

    interface Link extends Parent {
      type: 'link'
      data: {
        url: string
        title?: string
        children: StaticPhrasingContent[]
      }
    }

    interface Image {
      type: 'image'
      data: {
        url: string
        title?: string
        alt?: string
      }
    }

    interface LinkReference extends Parent {
      type: 'linkReference'
      data: {
        identifier: string
        label?: string
        referenceType: ReferenceType
        children: StaticPhrasingContent[]
      }
    }

    interface ImageReference {
      type: 'imageReference'
      data: {
        identifier: string
        label?: string
        referenceType: ReferenceType
        alt?: string
      }
    }

    interface Footnote extends Parent {
      type: 'footnote'
      data: { children: PhrasingContent[] }
    }

    interface FootnoteReference {
      type: 'footnoteReference'
      data: {
        identifier: string
        label?: string
      }
    }

    interface JSXImport extends Literal {
      type: 'import'
    }

    interface JSXExport extends Literal {
      type: 'export'
    }

    interface JSXValue extends Literal {
      type: 'jsx'
    }

    type JSX = JSXImport | JSXExport | JSXValue

    /**
      Each node in mdast falls into one or more categories of Content that group nodes with similar characteristics together.
     */
    type Content =
      | TopLevelContent
      | ListContent
      | TableContent
      | RowContent
      | PhrasingContent
      | JSX

    /**
      Top-level content represent the sections of document (block content), and metadata such as frontmatter and definitions.
     */
    type TopLevelContent =
      | BlockContent
      | FrontmatterContent
      | DefinitionContent
      | JSX

    /**
      Block content represent the sections of document.
     */
    type BlockContent =
      | Paragraph
      | Heading
      | ThematicBreak
      | Blockquote
      | List
      | Table
      | HTML
      | Code
      | JSX

    /**
      Frontmatter content represent out-of-band information about the document.

      If frontmatter is present, it must be limited to one node in the tree, and can only exist as a head.
     */
    type FrontmatterContent = YAML

    /**
      Definition content represents out-of-band information that typically affects the document through Association.
     */
    type DefinitionContent = Definition | FootnoteDefinition

    /**
      List content represent the items in a list.
    */
    type ListContent = ListItem

    /**
      Table content represent the rows in a table.
     */
    type TableContent = TableRow

    /**
      Row content represent the cells in a row.
     */
    type RowContent = TableCell

    /**
      Phrasing content represent the text in a document, and its markup.
     */
    type PhrasingContent = StaticPhrasingContent | Link | LinkReference

    /**
      StaticPhrasing content represent the text in a document, and its markup, that is not intended for user interaction.
     */
    type StaticPhrasingContent =
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
  }
}
