#!/usr/bin/env node

const path = require('path')
const fs = require('fs')
const yargs = require('yargs')

const { convertTypes, convertLogic, convertDocument } = require('./lib/index')

function addSharedArguments(yargs) {
  yargs.positional('file', {
    type: 'string',
    describe: 'The file to convert',
  })
  yargs.positional('targetFormat', {
    type: 'string',
    describe: 'The target format',
  })
}

yargs
  .scriptName('@lona/serialization')
  .usage('Usage: @lona/serialization <command> [options]')
  .command(
    'document file targetFormat',
    'Convert a Lona document to the specified format',
    yargs => {
      addSharedArguments(yargs)
      yargs.option('e', {
        alias: 'embeddedFormat',
        describe: 'The format of token blocks in MDX',
        type: 'string',
      })
    },
    argv => {
      const { file, targetFormat, sourceFormat, embeddedFormat } = argv
      const contents = fs.readFileSync(file, 'utf8')
      const converted = convertDocument(contents, targetFormat, {
        embeddedFormat,
      })
      console.log(converted)
    }
  )
  .command(
    'logic file targetFormat',
    'Convert a Lona logic (tokens) file to the specified format',
    yargs => addSharedArguments(yargs),
    argv => {
      const { file, targetFormat, sourceFormat } = argv
      const contents = fs.readFileSync(file, 'utf8')
      const converted = convertLogic(contents, targetFormat)
      console.log(converted)
    }
  )
  .command(
    'types file targetFormat',
    'Convert a Lona types file to the specified format',
    yargs => addSharedArguments(yargs),
    argv => {
      const { file, targetFormat, sourceFormat } = argv
      const contents = fs.readFileSync(file, 'utf8')
      const converted = convertTypes(contents, targetFormat)
      console.log(converted)
    }
  )
  .demandCommand(1, '\nPass --help to see all available commands and options.')
  .strict()
  .fail((msg, err, yargs) => {
    yargs.showHelp()
    console.log(msg)
  })
  .help().argv
