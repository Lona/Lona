#!/usr/bin/env node

import yargs from 'yargs'

import { getConfig, convert } from './index'

yargs
  .scriptName('lonac')
  .usage('Usage: lonac <command> [options]')
  .command(
    'config [workspace]',
    'Get the configuration of a Lona workspace',
    cli => {
      cli.positional('workspace', {
        describe: 'path to the Lona workspace',
        type: 'string',
        default: process.cwd(),
      })
    },
    argv => {
      if (typeof argv.workspace !== 'string') {
        throw new Error('workspace needs to be a string')
      }
      getConfig(argv.workspace)
        .then(config => {
          console.log(JSON.stringify(config, null, '  '))
        })
        .catch(err => {
          console.error(err)
          process.exit(1)
        })
    }
  )
  .command(
    'convert [path]',
    'Convert a file or workspace to a specific format',
    cli => {
      cli.positional('path', {
        describe: 'path to the Lona workspace or file',
        type: 'string',
        default: process.cwd(),
      })
      cli.option('format', {
        describe: 'format to convert it to',
        type: 'string',
        demandOption: true,
      })
    },
    argv => {
      if (typeof argv.path !== 'string') {
        throw new Error('path needs to be a string')
      }
      if (typeof argv.format !== 'string') {
        throw new Error('format option needs to be a string')
      }
      convert(argv.path, argv.format, argv)
        .then(result => {
          if (result) {
            if (typeof result === 'string') {
              console.log(result)
            } else {
              console.log(JSON.stringify(result, null, '  '))
            }
          }
        })
        .catch(err => {
          console.error(err)
          process.exit(1)
        })
    }
  )
  .demandCommand(1, 'Pass --help to see all available commands and options.')
  .strict()
  .fail(msg => {
    yargs.showHelp()
    console.log('\n' + msg)
  })
  .help('h')
  .alias('h', 'help').argv
