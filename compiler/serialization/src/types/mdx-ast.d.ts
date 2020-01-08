// Project: https://github.com/syntax-tree/mdast
// Project: https://github.com/mdx-js/specification#mdxast
// Definitions:

declare module 'mdx-ast' {
  import * as UNIST from 'unist'

  export namespace MDAST {
    type AlignType = 'left' | 'right' | 'center' | null
    type ReferenceType = 'shortcut' | 'collapsed' | 'full'

    /**
      Parent represents a node in mdast containing other nodes (said to be children).

      Its content is limited to only other mdast content.
    */
    interface Parent extends UNIST.Node {
      children: Content[]
    }

    /**
      Literal represents a node in mdast containing a value.

      Its value field is a string.
    */
    interface Literal extends UNIST.Literal {
      value: string
    }

    /**
      Root represents a document.

      Root can be used as the root of a tree, never as a child. Its content model is not limited to top-level content, but can contain any content with the restriction that all content must be of the same category.
    */
    interface Root extends Parent {
      type: 'root'
    }

    /**
      Paragraph represents a unit of discourse dealing with a particular point or idea.

      Paragraph can be used where block content is expected. Its content model is phrasing content.

      Example:
      ```
      Alpha bravo charlie.

      {
        type: 'paragraph',
        children: [{type: 'text', value: 'Alpha bravo charlie.'}]
      }
      ```
    */
    interface Paragraph extends Parent {
      type: 'paragraph'
      children: PhrasingContent[]
    }

    /**
      Heading represents a heading of a section.

      Heading can be used where block content is expected. Its content model is phrasing content.

      A `depth` field must be present. A value of `1` is said to be the highest rank and `6` the lowest.

      Example:
      ```
      # Alpha

      {
        type: 'heading',
        depth: 1,
        children: [{type: 'text', value: 'Alpha'}]
      }
      ```
    */
    interface Heading extends Parent {
      type: 'heading'
      depth: 1 | 2 | 3 | 4 | 5 | 6 | number
      children: PhrasingContent[]
    }

    /**
      ThematicBreak represents a thematic break, such as a scene change in a story, a transition to another topic, or a new document.

      ThematicBreak can be used where block content is expected. It has no content model.

      Example:
      ```
      ***

      {type: 'thematicBreak'}
      ```
     */
    interface ThematicBreak extends UNIST.Node {
      type: 'thematicBreak'
    }

    /**
      Blockquote represents a section quoted from somewhere else.

      Blockquote can be used where block content is expected. Its content model is also block content.

      Example:
      ```
      > Alpha bravo charlie.

      {
        type: 'blockquote',
        children: [{
          type: 'paragraph',
          children: [{type: 'text', value: 'Alpha bravo charlie.'}]
        }]
      }
      ```
     */
    interface Blockquote extends Parent {
      type: 'blockquote'
      children: BlockContent[]
    }

    /**
      List (Parent) represents a list of items.

      List can be used where block content is expected. Its content model is list content.

      An `ordered` field can be present. It represents that the items have been intentionally ordered (when `true`), or that the order of items is not important (when `false` or not present).

      If the `ordered` field is `true`, a `start` field can be present. It represents the starting number of the node.

      A `spread` field can be present. It represents that any of its items is separated by a blank line from its siblings (when `true`), or not (when `false` or not present).

      Example:
      ```
      1. [x] foo

      {
        type: 'list',
        ordered: true,
        start: 1,
        spread: false,
        children: [{
          type: 'listItem',
          checked: true,
          spread: false,
          children: [{
            type: 'paragraph',
            children: [{type: 'text', value: 'foo'}]
          }]
        }]
      }
      ```
     */
    interface List extends Parent {
      type: 'list'
      ordered?: boolean
      start?: number
      spread?: boolean
      children: ListContent[]
    }

    /**
      ListItem represents an item in a List.

      ListItem can be used where list content is expected. Its content model is block content.

      A `checked` field can be present. It represents whether the item is done (when `true`), not done (when `false`), or indeterminate or not applicable (when `null` or not present).

      A `spread` field can be present. It represents that the item contains two or more children separated by a blank line (when `true`), or not (when `false` or not present).

      Example:
      ```
      * [x] bar

      {
        type: 'listItem',
        checked: true,
        spread: false,
        children: [{
          type: 'paragraph',
          children: [{type: 'text', value: 'bar'}]
        }]
      }
      ```
     */
    interface ListItem extends Parent {
      type: 'listItem'
      checked?: boolean
      spread?: boolean
      children: BlockContent[]
    }

    /**
      Table represents two-dimensional data.

      Table can be used where block content is expected. Its content model is table content.

      The head of the node represents the labels of the columns.

      An `align` field can be present. If present, it must be a list of `alignTypes`. It represents how cells in columns are aligned.

      Example:
      ```
      | foo | bar |
      | :-- | :-: |
      | baz | qux |

      {
        type: 'table',
        align: ['left', 'center'],
        children: [
          {
            type: 'tableRow',
            children: [
              {
                type: 'tableCell',
                children: [{type: 'text', value: 'foo'}]
              },
              {
                type: 'tableCell',
                children: [{type: 'text', value: 'bar'}]
              }
            ]
          },
          {
            type: 'tableRow',
            children: [
              {
                type: 'tableCell',
                children: [{type: 'text', value: 'baz'}]
              },
              {
                type: 'tableCell',
                children: [{type: 'text', value: 'qux'}]
              }
            ]
          }
        ]
      }
      ```
     */
    interface Table extends Parent {
      type: 'table'
      align?: AlignType[]
      children: TableContent[]
    }

    /**
      TableRow represents a row of cells in a table.

      TableRow can be used where table content is expected. Its content model is row content.

      If the node is a head, it represents the labels of the columns for its parent Table.

      Example:
            ```
      | foo | bar |
      | :-- | :-: |
      | baz | qux |

      {
        type: 'table',
        align: ['left', 'center'],
        children: [
          {
            type: 'tableRow',
            children: [
              {
                type: 'tableCell',
                children: [{type: 'text', value: 'foo'}]
              },
              {
                type: 'tableCell',
                children: [{type: 'text', value: 'bar'}]
              }
            ]
          },
          {
            type: 'tableRow',
            children: [
              {
                type: 'tableCell',
                children: [{type: 'text', value: 'baz'}]
              },
              {
                type: 'tableCell',
                children: [{type: 'text', value: 'qux'}]
              }
            ]
          }
        ]
      }
      ```
     */
    interface TableRow extends Parent {
      type: 'tableRow'
      children: RowContent[]
    }

    /**
      TableCell represents a header cell in a Table, if its parent is a head, or a data cell otherwise.

      TableCell can be used where row content is expected. Its content model is phrasing content.

      Example:
            ```
      | foo | bar |
      | :-- | :-: |
      | baz | qux |

      {
        type: 'table',
        align: ['left', 'center'],
        children: [
          {
            type: 'tableRow',
            children: [
              {
                type: 'tableCell',
                children: [{type: 'text', value: 'foo'}]
              },
              {
                type: 'tableCell',
                children: [{type: 'text', value: 'bar'}]
              }
            ]
          },
          {
            type: 'tableRow',
            children: [
              {
                type: 'tableCell',
                children: [{type: 'text', value: 'baz'}]
              },
              {
                type: 'tableCell',
                children: [{type: 'text', value: 'qux'}]
              }
            ]
          }
        ]
      }
      ```
     */
    interface TableCell extends Parent {
      type: 'tableCell'
      children: PhrasingContent[]
    }

    /**
      HTML represents a fragment of raw HTML.

      HTML can be used where block or phrasing content is expected. Its content is represented by its value field.

      Example:
      ```
      <div>

      {type: 'html', value: '<div>'}
      ```
     */
    interface HTML extends Literal {
      type: 'html'
    }

    /**
      Code represents a block of preformatted text, such as ASCII art or computer code.

      Code can be used where block content is expected. Its content is represented by its value field.

      This node relates to the phrasing content concept InlineCode.

      A `lang` field can be present. It represents the language of computer code being marked up.

      If the `lang` field is present, a `meta` field can be present. It represents custom information relating to the node.

      Example:
      ```
          foo()

      {
        type: 'code',
        lang: null,
        meta: null,
        value: 'foo()'
      }
      ```

      or
      ```
      `\``js highlight-line="2"
      foo()
      bar()
      baz()
      `\``

      {
        type: 'code',
        lang: 'javascript',
        meta: 'highlight-line="2"',
        value: 'foo()\nbar()\nbaz()'
      }
      ```
     */
    interface Code extends Literal {
      type: 'code'
      lang?: string
      meta?: string
    }

    /**
      YAML represents a collection of metadata for the document in the YAML data serialisation language.

      YAML can be used where frontmatter content is expected. Its content is represented by its value field.

      Example:
      ```
      ---
      foo: bar
      ---

      {type: 'yaml', value: 'foo: bar'}
      ```
     */
    interface YAML extends Literal {
      type: 'yaml'
    }

    /**
      Definition represents a resource.

      Definition can be used where definition content is expected. It has no content model.

      An `identifier` field must be present. It can match an identifier field on another node. The `identifier` should be a unique identifier.

      A `label` field can be present. It represents the original value of the normalised identifier field.

      Definition should be associated with LinkReferences and ImageReferences.

      Example:
      ```
      [Alpha]: https://example.com

      {
        type: 'definition',
        identifier: 'alpha',
        label: 'Alpha',
        url: 'https://example.com',
        title: null
      }
      ```
     */
    interface Definition extends UNIST.Node {
      type: 'definition'
      identifier: string
      label?: string
      referenceType: ReferenceType
      url: string
      title?: string
    }

    /**
      FootnoteDefinition represents content relating to the document that is outside its flow.

      FootnoteDefinition can be used where definition content is expected. Its content model is block content.

      An `identifier` field must be present. It can match an identifier field on another node.

      A `label` field can be present. It represents the original value of the normalised identifier field.

      FootnoteDefinition should be associated with FootnoteReferences.

      Example:
      ```
      [^alpha]: bravo and charlie.

      {
        type: 'footnoteDefinition',
        identifier: 'alpha',
        label: 'alpha',
        children: [{
          type: 'paragraph',
          children: [{type: 'text', value: 'bravo and charlie.'}]
        }]
      }
      ```
     */
    interface FootnoteDefinition extends Parent {
      type: 'footnoteDefinition'
      identifier: string
      label?: string
      children: BlockContent[]
    }

    /**
      Text represents everything that is just text.

      Text can be used where phrasing content is expected. Its content is represented by its `value` field.

      Example:
      ```
      Alpha bravo charlie.

      {type: 'text', value: 'Alpha bravo charlie.'}
      ```
     */
    interface Text extends Literal {
      type: 'text'
    }

    /**
      Emphasis represents stress emphasis of its contents.

      Emphasis can be used where phrasing content is expected. Its content model is also phrasing content.

      Example:
      ```
      *alpha* _bravo_

      {
        type: 'paragraph',
        children: [
          {
            type: 'emphasis',
            children: [{type: 'text', value: 'alpha'}]
          },
          {type: 'text', value: ' '},
          {
            type: 'emphasis',
            children: [{type: 'text', value: 'bravo'}]
          }
        ]
      }
      ```
     */
    interface Emphasis extends Parent {
      type: 'emphasis'
      children: PhrasingContent[]
    }

    /**
      Strong represents strong importance, seriousness, or urgency for its contents.

      Strong can be used where phrasing content is expected. Its content model is also phrasing content.

      Example:
      ```
      **alpha** __bravo__

      {
        type: 'paragraph',
        children: [
          {
            type: 'strong',
            children: [{type: 'text', value: 'alpha'}]
          },
          {type: 'text', value: ' '},
          {
            type: 'strong',
            children: [{type: 'text', value: 'bravo'}]
          }
        ]
      }
      ```
     */
    interface Strong extends Parent {
      type: 'strong'
      children: PhrasingContent[]
    }

    /**
      Delete represents contents that are no longer accurate or no longer relevant.

      Delete can be used where phrasing content is expected. Its content model is also phrasing content.

      Example:
      ```
      ~~alpha~~

      {
        type: 'delete',
        children: [{type: 'text', value: 'alpha'}]
      }
      ```
     */
    interface Delete extends Parent {
      type: 'delete'
      children: PhrasingContent[]
    }

    /**
      InlineCode represents a fragment of computer code, such as a file name, computer program, or anything a computer could parse.

      InlineCode can be used where phrasing content is expected. Its content is represented by its value field.

      This node relates to the block content concept Code.

      Example:
      ```
      `foo()`

      {type: 'inlineCode', value: 'foo()'}
      ```
     */
    interface InlineCode extends Literal {
      type: 'inlineCode'
    }

    /**
      Break represents a line break, such as in poems or addresses.

      Break can be used where phrasing content is expected. It has no content model.

      Example:
      ```
      foo··
      bar

      {
        type: 'paragraph',
        children: [
          {type: 'text', value: 'foo'},
          {type: 'break'},
          {type: 'text', value: 'bar'}
        ]
      }
      ```
     */
    interface Break extends UNIST.Node {
      type: 'break'
    }

    /**
      Link (Parent) represents a hyperlink.

      A `url` field must be present. It represents a URL to the referenced resource.

      A `title` field can be present. It represents advisory information for the resource, such as would be appropriate for a tooltip.

      Link can be used where phrasing content is expected. Its content model is static phrasing content.

      Example:
      ```
      [alpha](https://example.com "bravo")

      {
        type: 'link',
        url: 'https://example.com',
        title: 'bravo',
        children: [{type: 'text', value: 'alpha'}]
      }
      ```
     */
    interface Link extends Parent {
      type: 'link'
      url: string
      title?: string
      children: StaticPhrasingContent[]
    }

    /**
      Image represents an image.

      A `url` field must be present. It represents a URL to the referenced resource.

      A `title` field can be present. It represents advisory information for the resource, such as would be appropriate for a tooltip.

      An `alt` field should be present. It represents equivalent content for environments that cannot represent the node as intended.

      Image can be used where phrasing content is expected. It has no content model, but is described by its alt field.

      Example:
      ```
      ![alpha](https://example.com/favicon.ico "bravo")

      {
        type: 'image',
        url: 'https://example.com/favicon.ico',
        title: 'bravo',
        alt: 'alpha'
      }
      ```
     */
    interface Image extends UNIST.Node {
      type: 'image'
      url: string
      title?: string
      alt?: string
    }

    /**
      LinkReference represents a hyperlink through association, or its original source if there is no association.

      A `referenceType` field must be present. Its value must be a `referenceType`. It represents the explicitness of the reference.

      LinkReference can be used where phrasing content is expected. Its content model is static phrasing content.

      LinkReferences should be associated with a Definition.

      Example
      ```
      [alpha][Bravo]

      {
        type: 'linkReference',
        identifier: 'bravo',
        label: 'Bravo',
        referenceType: 'full',
        children: [{type: 'text', value: 'alpha'}]
      }
      ```
     */
    interface LinkReference extends Parent {
      type: 'linkReference'
      identifier: string
      label?: string
      referenceType: ReferenceType
      children: StaticPhrasingContent[]
    }

    /**
      ImageReference represents an image through association, or its original source if there is no association.

      ImageReference can be used where phrasing content is expected. It has no content model, but is described by its alt field.

      A `referenceType` field must be present. Its value must be a `referenceType`. It represents the explicitness of the reference.

      An `alt` field should be present. It represents equivalent content for environments that cannot represent the node as intended.

      ImageReference should be associated with a Definition.

      Example:
      ```
      ![alpha][bravo]

      {
        type: 'imageReference',
        identifier: 'bravo',
        label: 'bravo',
        referenceType: 'full',
        alt: 'alpha'
      }
      ```
     */
    interface ImageReference extends UNIST.Node {
      type: 'imageReference'
      identifier: string
      label?: string
      referenceType: ReferenceType
      alt?: string
    }

    /**
      Footnote represents content relating to the document that is outside its flow.

      Footnote can be used where phrasing content is expected. Its content model is also phrasing content.

      Example:
      ```
      [^alpha bravo]

      {
        type: 'footnote',
        children: [{type: 'text', value: 'alpha bravo'}]
      }
      ```
     */
    interface Footnote extends Parent {
      type: 'footnote'
      children: PhrasingContent[]
    }

    /**
      FootnoteReference represents a marker through association.

      FootnoteReference can be used where phrasing content is expected. It has no content model.

      An `identifier` field must be present. It can match an identifier field on another node.

      A `label` field can be present. It represents the original value of the normalised identifier field.

      FootnoteReference should be associated with a FootnoteDefinition.

      Example:
      ```
      [^alpha]

      {
        type: 'footnoteReference',
        identifier: 'alpha',
        label: 'alpha'
      }
      ```
     */
    interface FootnoteReference extends UNIST.Node {
      type: 'footnoteReference'
      identifier: string
      label?: string
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
