const xml = `<?xml version="1.0"?>
<Variable name="x" type="Array(Number)">
  <Literal type="Number" value="42"/>
</Variable>`

const code = `let x: Array<Number> = [
  42
]`

const json = {
  data: {
    annotation: {
      data: {
        genericArguments: [
          {
            data: {
              genericArguments: [],
              id: '0',
              identifier: {
                id: '0',
                isPlaceholder: false,
                string: 'Number',
                type: 'identifier',
              },
            },
            type: 'typeIdentifier',
          },
        ],
        id: '0',
        identifier: {
          id: '0',
          isPlaceholder: false,
          string: 'Array',
          type: 'identifier',
        },
      },
      type: 'typeIdentifier',
    },
    id: '0',
    initializer: {
      data: {
        id: '0',
        literal: {
          data: {
            id: '0',
            value: [
              {
                data: {
                  id: '0',
                  literal: {
                    data: {
                      id: '0',
                      value: 42,
                    },
                    type: 'number',
                  },
                },
                type: 'literalExpression',
              },
              {
                data: {
                  id: '0',
                },
                type: 'placeholder',
              },
            ],
          },
          type: 'array',
        },
      },
      type: 'literalExpression',
    },
    name: {
      id: '0',
      name: 'x',
      type: 'pattern',
    },
  },
  type: 'variable',
}

module.exports = { json, xml, code }
