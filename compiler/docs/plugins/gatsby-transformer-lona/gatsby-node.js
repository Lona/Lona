const {
  GraphQLObjectType,
  GraphQLList,
  GraphQLString,
  GraphQLBoolean,
  GraphQLInt,
} = require(`graphql`)

exports.setFieldsOnGraphQLNodeType = ({ type }) => {
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
          subtitles: { type: new GraphQLList(GraphQLString) },
          showSubtitlesInSidebar: { type: GraphQLBoolean },
          order: { type: GraphQLInt },
          icon: { type: GraphQLString },
        },
      }),
      resolve(node) {
        if (
          node.type !== 'Component' &&
          node.type !== 'LonaDocument' &&
          node.type !== 'Colors' &&
          node.type !== 'TextStyles'
        ) {
          return undefined
        }

        let filePath =
          node.name === 'README'
            ? `/${node.dir}`
            : `/${node.dir ? `${node.dir}/` : ''}${node.name}`
        const sections = filePath.split('/').filter(x => x)
        const { content } = node.internal

        if (node.type === 'Component') {
          if (content.doc) {
            // component = getFilePath(node, content.doc)
          }
        }

        if (node.type === 'Colors' || node.type === 'TextStyles') {
          sections.unshift('tokens')
          filePath = `/tokens${filePath}`
        }

        return {
          hidden: content.hidden,
          title:
            node.name === 'README' ? sections[sections.length - 1] : node.name,
          path: filePath,
          content,
          sections,
          subtitles: content.subtitles || [],
          showSubtitlesInSidebar: content.showSubtitlesInSidebar || false,
          order: content.order,
          icon: content.icon,
        }
      },
    },
  }
}

exports.onCreateNode = require('./on-create-lona-node')
