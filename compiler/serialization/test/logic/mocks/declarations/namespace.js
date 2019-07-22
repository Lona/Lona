const xml = `<?xml version="1.0"?>
<Declaration.Namespace name="Colors"/>`

const json = {
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
}

module.exports = { json, xml }
