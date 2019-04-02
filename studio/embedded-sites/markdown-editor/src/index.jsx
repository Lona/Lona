/* globals document */
import 'babel-polyfill'
import 'regenerator-runtime'

import './styles/reset.css'
import 'github-markdown-css/github-markdown.css'

import ThemedStyleSheet from 'react-with-styles/lib/ThemedStyleSheet'
import aphroditeInterface from 'react-with-styles-interface-amp-aphrodite'

import React from 'react'
import ReactDOM from 'react-dom'

import App from './App'

ThemedStyleSheet.registerTheme({})
ThemedStyleSheet.registerInterface(aphroditeInterface)

ReactDOM.render(<App />, document.getElementById('root'))
