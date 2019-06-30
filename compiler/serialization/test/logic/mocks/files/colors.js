const xml = `<?xml version="1.0"?>
<Program>
  <Declaration.ImportDeclaration name="Prelude"/>
  <Declaration.Namespace name="Colors">
    <Variable name="a" type="Color" value="#FF3409"/>
    <Namespace name="Nested">
      <Variable name="b" type="Color" value="#3449FF"/>
    </Namespace>
  </Declaration.Namespace>
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
          content: {
            data: {
              declarations: [
                {
                  data: {
                    annotation: {
                      data: {
                        genericArguments: [],
                        id: '0',
                        identifier: {
                          id: '0',
                          isPlaceholder: false,
                          string: 'Color',
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
                            value: '#FF3409',
                          },
                          type: 'color',
                        },
                      },
                      type: 'literalExpression',
                    },
                    name: {
                      id: '0',
                      name: 'a',
                    },
                  },
                  type: 'variable',
                },
                {
                  data: {
                    declarations: [
                      {
                        data: {
                          annotation: {
                            data: {
                              genericArguments: [],
                              id: '0',
                              identifier: {
                                id: '0',
                                isPlaceholder: false,
                                string: 'Color',
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
                                  value: '#3449FF',
                                },
                                type: 'color',
                              },
                            },
                            type: 'literalExpression',
                          },
                          name: {
                            id: '0',
                            name: 'b',
                          },
                        },
                        type: 'variable',
                      },
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
                      name: 'Nested',
                    },
                  },
                  type: 'namespace',
                },
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
