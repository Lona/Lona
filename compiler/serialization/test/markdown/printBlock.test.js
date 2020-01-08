/* eslint-disable import/no-unresolved */
import { printMdxNode } from '../../src/index'

test('prints a markdown block', () => {
  const json = {
    type: 'paragraph',
    data: {
      children: [
        {
          type: 'text',
          data: {
            value: 'a ',
          },
        },
        {
          type: 'strong',
          data: {
            children: [
              {
                type: 'text',
                data: {
                  value: 'b',
                },
              },
            ],
          },
        },
      ],
    },
  }

  const mdx = printMdxNode(json)

  expect(mdx).toBe('a **b**')
})
