/* globals document */
import 'babel-polyfill'
import 'regenerator-runtime'

import './styles/reset.css'
import 'github-markdown-css/github-markdown.css'

import ThemedStyleSheet from 'react-with-styles/lib/ThemedStyleSheet'
import aphroditeInterface from 'react-with-styles-interface-amp-aphrodite'

import React from 'react'
import ReactDOM from 'react-dom'

import { appendCSS } from './utils/styles'
import queryParams from './utils/queryParams'
import App from './App'

if (queryParams.fullscreen) {
  appendCSS(
    `html, body, #root {
      height: 100%;
      overflow: hidden;
    }`
  )
}

ThemedStyleSheet.registerTheme(queryParams.theme)
ThemedStyleSheet.registerInterface(aphroditeInterface)

ReactDOM.render(
  <App
    editable={queryParams.editable}
    preview={queryParams.preview}
    fullscreen={queryParams.fullscreen}
  />,
  document.getElementById('root')
)
