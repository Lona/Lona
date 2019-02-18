const fs = require('fs-extra')
const path = require('path')
const loadConfig = require('./load-config')

const config = loadConfig()

const dest = path.join(config.cwd, config.docsFolder || './docs')

module.exports = () =>
  fs
    .remove(dest)
    .then(() => fs.ensureDir(dest))
    .then(() => fs.copy(path.join(__dirname, '../public'), dest))
