const toMarkdown = require('../../lib/mdastUtilToMarkdown')

describe('convert mdast to markdown', () => {
  test('root', () => {
    const json = {
      type: 'root',
      children: [
        {
          type: 'paragraph',
          children: [
            {
              type: 'text',
              value: 'a',
            },
          ],
        },
      ],
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
})
