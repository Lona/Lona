const xml = `<?xml version="1.0"?>
<Program>
  <Declaration.Variable name="x" type="Number" value="123"/>
</Program>`

const declaration = {
  data: {
    content: {
      data: {
        annotation: {
          data: {
            genericArguments: [],
            id: '0',
            identifier: {
              id: '0',
              isPlaceholder: false,
              string: 'Number',
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
                value: 123,
              },
              type: 'number',
            },
          },
          type: 'literalExpression',
        },
        name: {
          id: '0',
          name: 'x',
        },
      },
      type: 'variable',
    },
    id: '0',
  },
  type: 'declaration',
}

const json = {
  data: {
    block: [
      declaration,
      {
        data: {
          id: '0',
        },
        type: 'placeholder',
      },
    ],
    id: '0',
  },
  type: 'program',
}

module.exports = { json, xml }
