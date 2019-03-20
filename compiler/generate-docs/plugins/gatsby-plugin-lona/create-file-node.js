const path = require('path')
const crypto = require('crypto')
const mime = require('mime')
const fs = require('fs-extra')

function digest(x) {
  return crypto
    .createHash(`md5`)
    .update(x)
    .digest(`hex`)
}
exports.digest = digest

const createId = _path => `${_path} >>> Lona`
exports.createId = createId

exports.createArtifactsNode = (artifacts, { type, cwd }) => {
  const content = JSON.stringify(artifacts)
  return JSON.parse(
    JSON.stringify({
      id: 'artifacts >>> Lona',
      children: [],
      parent: `___SOURCE___`,
      type,
      internal: {
        contentDigest: digest(content),
        mediaType: 'text/html',
        type: 'LonaFile',
        content,
      },
      absolutePath: path.join(cwd, 'assets'),
      relativePath: './assets',
      extension: 'html',
    })
  )
}

exports.createFileNode = (pathToFile, { type, cwd }) => {
  const parsedSlashed = path.parse(pathToFile)
  const slashedFile = {
    ...parsedSlashed,
    absolutePath: path.join(cwd, pathToFile),
    relativePath: path.relative(cwd, path.join(cwd, pathToFile)),
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
        contentDigest: digest(slashedFile.absolutePath),
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
