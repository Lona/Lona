const {
  GraphQLObjectType,
  GraphQLList,
  GraphQLString,
  GraphQLBoolean,
  GraphQLInt,
} = require(`graphql`)

module.exports = function setFieldsOnGraphQLNodeType({ type }) {
  if (type.name !== 'LonaFile') {
    return {}
  }

  return {
    lona: {
      type: new GraphQLObjectType({
        name: `Lona`,
        fields: {
          hidden: { type: GraphQLBoolean },
          title: { type: GraphQLString },
          path: { type: GraphQLString },
          content: { type: GraphQLString },
          sections: { type: new GraphQLList(GraphQLString) },
          order: { type: GraphQLInt },
          icon: { type: GraphQLString },
        },
      }),
      resolve(node) {
        if (
          node.type !== 'Component' &&
          node.type !== 'LonaDocument' &&
          node.type !== 'Colors' &&
          node.type !== 'TextStyles' &&
          node.type !== 'Gradients' &&
          node.type !== 'Shadows'
        ) {
          return undefined
        }

        const filePath =
          node.type === 'LonaDocument' && node.name === 'README'
            ? `/${node.dir}`
            : `/${node.dir ? `${node.dir}/` : ''}${node.name}`
        const sections = filePath.split('/').filter(x => x)
        const { content } = node.internal

        return {
          hidden: content.hidden,
          title:
            node.name === 'README' ? sections[sections.length - 1] : node.name,
          path: filePath,
          content,
          sections,
          order: content.order,
          icon: content.icon,
        }
      },
    },
  }
}
