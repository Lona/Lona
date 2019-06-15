#!/usr/bin/env node

const fs = require('fs')
const { convertTypes, convertLogic } = require('./lib/index')

const [, , filename, kind, format] = process.argv

if (!filename) {
  console.log('No filename')
  process.exit(1)
}

if (kind !== 'types' && kind !== 'logic') {
  console.log('Only type and logic files support conversion currently')
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

function convertLogicFile(file, targetFormat) {
  const contents = fs.readFileSync(filename, 'utf8')

  return convertLogic(contents, targetFormat)
}

try {
  switch (kind) {
    case 'types': {
      const convertedString = convertTypesFile(filename, format)
      console.log(convertedString)
      break
    }
    case 'logic': {
      const convertedString = convertLogicFile(filename, format)
      console.log(convertedString)
      break
    }
    default:
      console.log('Unknown kind of file')
  }
} catch (e) {
  console.error(e)
  process.exit(1)
}
