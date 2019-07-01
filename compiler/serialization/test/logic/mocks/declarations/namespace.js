const xml = `<?xml version="1.0"?>
<Program>
  <Declaration.Namespace name="Colors"/>
</Program>`

const json = {
  data: {
    block: [
      {
        data: {
          content: {
            data: {
              declarations: [
                {
                  data: {
                    id: '0',
                  },
                  type: 'placeholder',
                },
              ],
              id: '0',
              name: {
                id: '0',
                name: 'Colors',
              },
            },
            type: 'namespace',
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
