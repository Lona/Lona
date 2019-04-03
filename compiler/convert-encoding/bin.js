#!/usr/bin/env node

const fs = require('fs')
const { convertTypes } = require('./lib/index')

const [, , filename, format] = process.argv

if (!filename) {
  console.log('No filename')
  process.exit(1)
}

if (!format) {
  console.log('No encoding format')
  process.exit(1)
}

function convertTypesFile(file, targetEncodingFormat) {
  const contents = fs.readFileSync(filename, 'utf8')

  return convertTypes(contents, targetEncodingFormat)
}

try {
  const convertedString = convertTypesFile(filename, format)
  console.log(convertedString)
} catch (e) {
  console.error(e)
  process.exit(1)
}
