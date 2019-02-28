const path = require('path')
const crypto = require('crypto')
const mime = require('mime')
const fs = require('fs-extra')

const createId = _path => `${_path} >>> Lona`

exports.createId = createId

exports.createFileNode = (pathToFile, { type, cwd }) => {
  const parsedSlashed = path.parse(pathToFile)
  const slashedFile = {
    ...parsedSlashed,
    absolutePath: path.join(cwd, pathToFile),
  }

  let mediaType
  if (slashedFile.ext === '.component') {
    mediaType = 'application/json'
  } else if (slashedFile.ext === '.mdx') {
    mediaType = 'text/x-markdown'
  } else {
    mediaType = mime.getType(slashedFile.ext)
  }

  return Promise.all([
    fs.stat(slashedFile.absolutePath),
    fs.readFile(slashedFile.absolutePath, 'utf8'),
  ]).then(([stats, content]) =>
    Promise.resolve()
      .then(() => ({
        contentDigest: crypto
          .createHash(`md5`)
          .update(slashedFile.absolutePath)
          .digest(`hex`),
        mediaType,
        type: 'LonaFile',
        content,
      }))
      .then(internal =>
        JSON.parse(
          JSON.stringify({
            // Don't actually make the File id the absolute path as otherwise
            // people will use the id for that and ids shouldn't be treated as
            // useful information.
            id: createId(pathToFile),
            children: [],
            parent: `___SOURCE___`,
            type,
            internal,
            absolutePath: slashedFile.absolutePath,
            relativePath: path.relative(cwd, slashedFile.absolutePath),
            extension: slashedFile.ext.slice(1).toLowerCase(),
            size: stats.size,
            modifiedTime: stats.mtime,
            accessTime: stats.atime,
            changeTime: stats.ctime,
            birthTime: stats.birthtime,
            ...slashedFile,
            ...stats,
          })
        )
      )
  )
}
