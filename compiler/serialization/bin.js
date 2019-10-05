#!/usr/bin/env node

const fs = require('fs')
const { convertTypes, convertLogic, convertDocument } = require('./lib/index')

const [, , filename, kind, targetFormat, sourceFormat] = process.argv

const usage = 'usage: filename kind targetFormat [sourceFormat]'

if (!filename) {
  console.log('No filename')
  console.log(usage)
  process.exit(1)
}

if (kind !== 'types' && kind !== 'logic' && kind !== 'document') {
  console.log('Only type and logic files support conversion currently')
  console.log(usage)
  process.exit(1)
}

if (!targetFormat) {
  console.log('No serialization targetFormat')
  console.log(usage)
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

function convertDocumentFile(file, targetFormat) {
  const contents = fs.readFileSync(filename, 'utf8')

  return convertDocument(contents, targetFormat, {
    sourceFormat: sourceFormat || 'mdx',
  })
}

try {
  switch (kind) {
    case 'types': {
      const convertedString = convertTypesFile(filename, targetFormat)
      console.log(convertedString)
      break
    }
    case 'logic': {
      const convertedString = convertLogicFile(filename, targetFormat)
      console.log(convertedString)
      break
    }
    case 'document': {
      const convertedString = convertDocumentFile(filename, targetFormat)
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
