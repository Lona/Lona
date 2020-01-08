#!/usr/bin/env node
/* eslint-disable no-console */

const fs = require('fs')
const yargs = require('yargs')

const {
  convertTypes,
  convertLogic,
  convertDocument,
  extractProgram,
} = require('./build/index')

function addSharedArguments(cli) {
  cli.positional('file', {
    type: 'string',
    describe: 'The file to convert',
  })
  cli.positional('targetFormat', {
    type: 'string',
    describe: 'The target format',
  })
}

// eslint-disable-next-line no-unused-expressions
yargs
  .scriptName('@lona/serialization')
  .usage('Usage: @lona/serialization <command> [options]')
  .command(
    'document file targetFormat',
    'Convert a Lona document to the specified format',
    cli => {
      addSharedArguments(cli)
      cli.option('e', {
        alias: 'embeddedFormat',
        describe: 'The format of token blocks in MDX',
        type: 'string',
      })
    },
    argv => {
      const { file, targetFormat, embeddedFormat } = argv
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
    cli => addSharedArguments(cli),
    argv => {
      const { file, targetFormat } = argv
      const contents = fs.readFileSync(file, 'utf8')
      const converted = convertLogic(contents, targetFormat)
      console.log(converted)
    }
  )
  .command(
    'types file targetFormat',
    'Convert a Lona types file to the specified format',
    cli => addSharedArguments(cli),
    argv => {
      const { file, targetFormat } = argv
      const contents = fs.readFileSync(file, 'utf8')
      const converted = convertTypes(contents, targetFormat)
      console.log(converted)
    }
  )
  .command(
    'program file',
    'Extract the executable contents of a Lona document',
    () => {},
    argv => {
      const { file } = argv
      const contents = fs.readFileSync(file, 'utf8')
      const converted = extractProgram(contents)
      console.log(converted)
    }
  )
  .demandCommand(1, 'Pass --help to see all available commands and options.')
  .strict()
  .fail((msg, err, cli) => {
    cli.showHelp()
    // eslint-disable-next-line prefer-template
    console.log('\n' + msg)
  })
  .help().argv
