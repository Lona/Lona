const toMarkdown = require('../../lib/mdastUtilToMarkdown')

const aParagraph = {
  type: 'paragraph',
  children: [
    {
      type: 'text',
      value: 'a',
    },
  ],
}

const bParagraph = {
  type: 'paragraph',
  children: [
    {
      type: 'text',
      value: 'b',
    },
  ],
}

const cParagraph = {
  type: 'paragraph',
  children: [
    {
      type: 'text',
      value: 'c',
    },
  ],
}

describe('convert mdast to markdown', () => {
  test('root', () => {
    const json = {
      type: 'root',
      children: [aParagraph],
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('a')
  })

  test('string', () => {
    const json = {
      type: 'strong',
      children: [
        {
          type: 'text',
          value: 'a',
        },
      ],
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('**a**')
  })

  test('emphasis', () => {
    const json = {
      type: 'emphasis',
      children: [
        {
          type: 'text',
          value: 'a',
        },
      ],
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('_a_')
  })

  test('inline code', () => {
    const json = {
      type: 'inlineCode',
      value: 'a',
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('`a`')
  })

  test('paragraph', () => {
    const json = {
      type: 'paragraph',
      children: [
        {
          type: 'text',
          value: 'a ',
        },
        {
          type: 'strong',
          children: [
            {
              type: 'text',
              value: 'b',
            },
          ],
        },
      ],
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('a **b**')
  })

  test('heading', () => {
    const json = {
      type: 'heading',
      depth: 2,
      children: [
        {
          type: 'text',
          value: 'a',
        },
      ],
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('## a')
  })

  test('image', () => {
    const json = {
      type: 'image',
      alt: 'alt',
      url: 'url',
      children: [],
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('![alt](url)')
  })

  test('link', () => {
    const json = {
      type: 'link',
      url: 'url',
      children: [
        {
          type: 'text',
          value: 'a',
        },
      ],
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('[a](url)')
  })

  test('thematicBreak', () => {
    const json = {
      type: 'thematicBreak',
      children: [],
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('---')
  })

  test('blockquote', () => {
    const json = {
      type: 'blockquote',
      children: [
        {
          type: 'text',
          value: 'a',
        },
      ],
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('> a')
  })

  test('blockquote with break', () => {
    const json = {
      type: 'blockquote',
      children: [
        {
          type: 'text',
          value: 'a',
        },
        {
          type: 'break',
        },
        {
          type: 'text',
          value: 'b',
        },
      ],
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('> a  \n> b')
  })

  test('unordered list', () => {
    const json = {
      type: 'list',
      spread: false,
      ordered: false,
      children: [
        {
          type: 'listItem',
          children: [aParagraph],
        },
        {
          type: 'listItem',
          children: [bParagraph],
        },
      ],
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('- a\n- b')
  })

  test('unordered list with multiple block children', () => {
    const json = {
      type: 'list',
      spread: false,
      ordered: false,
      children: [
        {
          type: 'listItem',
          children: [aParagraph, bParagraph],
        },
        {
          type: 'listItem',
          children: [bParagraph],
        },
      ],
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('- a\n  \n  b\n- b')
  })

  test('unordered nested list', () => {
    const json = {
      type: 'list',
      spread: false,
      ordered: false,
      children: [
        {
          type: 'listItem',
          children: [
            aParagraph,
            {
              type: 'list',
              spread: false,
              ordered: false,
              children: [
                {
                  type: 'listItem',
                  children: [bParagraph],
                },
                {
                  type: 'listItem',
                  children: [cParagraph],
                },
              ],
            },
          ],
        },
      ],
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('- a\n  \n  - b\n  - c')
  })

  test('ordered list', () => {
    const json = {
      type: 'list',
      ordered: true,
      spread: false,
      children: [
        {
          type: 'listItem',
          children: [aParagraph],
        },
        {
          type: 'listItem',
          children: [bParagraph],
        },
      ],
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe('1. a\n2. b')
  })

  test('page', () => {
    const json = {
      type: 'page',
      value: 'child',
    }

    const mdx = toMarkdown(json)

    expect(mdx).toBe(`<a class="page" href="child" />`)
  })
})
