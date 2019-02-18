#!/usr/bin/env node

const yargs = require('yargs')

// eslint-disable-next-line no-unused-expressions
yargs
  .command(require('./build'))
  .usage(
    `
For help with a specific command, enter:
  lona-docs help [command]
`
  )
  .help()
  .alias('h', 'help')
  .demandCommand()
  .strict().argv
