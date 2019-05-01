#!/usr/bin/env node

// This file is here to hack into Gatsby. Gatsby is not made to be run outside
// the current directly and output paths aren't configurable.
// so we need some hack to make it work while waiting for it to be a gatsby feature
// (discussions in progress)
// ideally this should just be removed

const { link } = require('linkfs')
const mock = require('mock-require')
const fs = require('fs')
const path = require('path')

// parse the arguments
const { argv } = process
argv._ = argv.slice(2)
argv.noColor = argv.some(arg => arg === '--no-color')
argv.verbose = argv.some(arg => arg === '--verbose')
argv.prefixPaths = argv.some(arg => arg === '--prefix-paths')
argv.port = 8000
argv.host = 'localhost'
/* eslint-disable prefer-destructuring */
argv.command = argv[2]
argv.buildDir = (
  argv.find(arg => arg.indexOf('--build-dir') === 0) || '--build-dir=""'
)
  .split('--build-dir="')[1]
  .split('"')[0]
argv.cacheDir = (
  argv.find(arg => arg.indexOf('--cache-dir') === 0) || '--cache-dir=""'
)
  .split('--cache-dir="')[1]
  .split('"')[0]
/* eslint-enable */

// redirect the gatsby output paths to what we want
const linkedFs = link(
  fs,
  [
    [`${process.cwd()}/.cache`, argv.cacheDir],
    [`${process.cwd()}/public`, argv.buildDir],
  ].filter(x => x[1])
)

// those are missing in linkfs
linkedFs.ReadStream = fs.ReadStream
linkedFs.WriteStream = fs.WriteStream

// replace fs with linkfs globally
mock('fs', linkedFs)

// eslint-disable-next-line import/no-extraneous-dependencies
const report = require('gatsby-cli/lib/reporter')

report.setVerbose(!!argv.verbose)
if (argv.some(arg => arg === '--no-color')) {
  // disables colors in popular terminal output coloring packages
  //  - chalk: see https://www.npmjs.com/package/chalk#chalksupportscolor
  //  - ansi-colors: see https://github.com/doowb/ansi-colors/blob/8024126c7115a0efb25a9a0e87bc5e29fd66831f/index.js#L5-L7
  process.env.FORCE_COLOR = `0`
}

report.setNoColor(!!argv.noColor)

process.env.gatsby_log_level = argv.verbose ? `verbose` : `normal`
report.verbose(`set gatsby_log_level: "${process.env.gatsby_log_level}"`)

process.env.gatsby_executing_command = argv.command

if (argv.command === 'develop') {
  process.env.NODE_ENV = process.env.NODE_ENV || 'development'
} else {
  process.env.NODE_ENV = 'production'
}

process.env.GATSBY_BUILD_DIR =
  argv.buildDir || path.join(process.cwd(), 'public')
process.env.GATSBY_CACHE_DIR =
  argv.cacheDir || path.join(process.cwd(), '.cache')

const gatsby = require(`gatsby/dist/commands/${argv.command}`)
const sitePackageJson = require('../package.json')

gatsby({
  ...argv,
  directory: process.cwd(),
  browserslist: sitePackageJson.browserslist || [`>0.25%`, `not dead`],
  sitePackageJson,
  report,
  useYarn: true,
})
  .then(() => {
    if (argv.command !== 'develop') {
      process.exit(0)
    }
  })
  .catch(err => {
    console.error(err)
    process.exit(1)
  })
