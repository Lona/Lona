/* eslint-disable import/no-unresolved */
import { convertDocument, SERIALIZATION_FORMAT } from '../../src/index'

describe('mdx <-> json', () => {
  describe('root', () => {
    const mdx = `# heading

<a class="page" href="child.md">child</a>

a`

    const json = {
      children: [
        {
          type: 'heading',
          data: {
            depth: 1,
            children: [
              {
                type: 'text',
                data: {
                  value: 'heading',
                },
              },
            ],
          },
        },
        {
          type: 'page',
          data: {
            value: 'child',
            url: 'child.md',
          },
        },
        {
          type: 'paragraph',
          data: {
            children: [
              {
                type: 'text',
                data: {
                  value: 'a',
                },
              },
            ],
          },
        },
      ],
    }

    test('mdx -> json', () => {
      const converted = JSON.parse(
        convertDocument(mdx, SERIALIZATION_FORMAT.JSON)
      )
      expect(converted).toStrictEqual(json)
    })

    test('json -> mdx', () => {
      const converted = convertDocument(
        JSON.stringify(json),
        SERIALIZATION_FORMAT.SOURCE
      )
      expect(converted).toBe(mdx)
    })
  })

  describe('image', () => {
    const mdx = `![alt](url)`

    const json = {
      children: [
        {
          type: 'image',
          data: {
            alt: 'alt',
            url: 'url',
            title: null,
          },
        },
      ],
    }

    test('mdx -> json', () => {
      const converted = JSON.parse(
        convertDocument(mdx, SERIALIZATION_FORMAT.JSON)
      )
      expect(converted).toStrictEqual(json)
    })

    test('json -> mdx', () => {
      const converted = convertDocument(
        JSON.stringify(json),
        SERIALIZATION_FORMAT.SOURCE
      )
      expect(converted).toBe(mdx)
    })
  })
})
