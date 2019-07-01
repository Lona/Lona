const xml = `<?xml version="1.0"?>
<Program>
  <Declaration.ImportDeclaration name="Prelude"/>
</Program>`

const json = {
  data: {
    block: [
      {
        data: {
          content: {
            data: {
              id: '0',
              name: {
                id: '0',
                name: 'Prelude',
              },
            },
            type: 'importDeclaration',
          },
          id: '0',
        },
        type: 'declaration',
      },
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
