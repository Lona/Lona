#!/usr/bin/env node

const fs = require('fs')
const { convertTypes } = require('./lib/index')

const [, , filename, kind, format] = process.argv

if (!filename) {
  console.log('No filename')
  process.exit(1)
}

if (kind !== 'types') {
  console.log('Only converting types files is supported currently')
  process.exit(1)
}

if (!format) {
  console.log('No serialization format')
  process.exit(1)
}

function convertTypesFile(file, targetFormat) {
  const contents = fs.readFileSync(filename, 'utf8')

  return convertTypes(contents, targetFormat)
}

try {
  const convertedString = convertTypesFile(filename, format)
  console.log(convertedString)
} catch (e) {
  console.error(e)
  process.exit(1)
}
