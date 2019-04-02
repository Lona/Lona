#!/usr/bin/env node

const { convertTypesFile } = require('./lib/index')

const [, , filename, format] = process.argv

if (!filename) {
  console.log('No filename')
  process.exit(1)
}

if (!format) {
  console.log('No encoding format')
  process.exit(1)
}

const convertedString = convertTypesFile(filename, format)

console.log(convertedString)
