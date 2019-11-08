const { convertDocument, SERIALIZATION_FORMAT } = require('../../lib/index')

describe('mdx <-> json', () => {
  describe('root', () => {
    const mdx = `# heading

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
                  children: [],
                },
              },
            ],
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
                  children: [],
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
            children: [],
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
