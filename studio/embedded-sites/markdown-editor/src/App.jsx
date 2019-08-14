/* globals window */
import React from 'react'
import { withStyles } from 'react-with-styles'
import ReactMarkdown from 'react-markdown'

import Editor from './components/Editor'

function sendNotification(notification) {
  try {
    window.webkit.messageHandlers.notification.postMessage(notification)
  } catch (e) {
    // eslint-disable-next-line no-console
    console.log(
      'No webkit messageHandlers -- if this is running within Lona Studio, something bad happened'
    )
  }
}

let initialValue = ''
let onChangeValue = () => {}

window.update = ({ type, payload }) => {
  switch (type) {
    case 'setDescription':
      initialValue = payload
      return onChangeValue(payload)
    default:
      return undefined
  }
}

sendNotification({ type: 'ready' })

class App extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      value: initialValue,
    }

    this.handleChange = this.handleChange.bind(this)

    onChangeValue = value => {
      this.setState({ value })
    }
  }

  handleChange(code) {
    this.setState({ value: code })
    sendNotification({ type: 'description', payload: code })
  }

  render() {
    // eslint-disable-next-line react/prop-types
    const { styles, css, editable, preview, fullscreen } = this.props
    const { value } = this.state

    const markdownCss = {
      ...css(styles.column, fullscreen && styles.paddedContent),
    }
    markdownCss.className += ' markdown-body'

    return (
      <div {...css(styles.row)}>
        {editable && (
          <Editor
            value={value}
            filename="README.md"
            onChange={this.handleChange}
            errorLineNumber={false}
          />
        )}
        {editable && preview && <div {...css(styles.divider)} />}
        {preview && (
          <div {...css(styles.column)}>
            <ReactMarkdown {...markdownCss} source={value} escapeHtml={false} />
          </div>
        )}
      </div>
    )
  }
}

export default withStyles(theme => ({
  container: {
    backgroundColor: 'red',
  },
  column: {
    flex: '1',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'stretch',
    minWidth: 0,
    minHeight: 0,
    // overflow: 'hidden',
    position: 'relative',
    color: theme.text,
  },
  divider: {
    width: '1px',
    backgroundColor: theme.divider,
  },
  paddedContent: {
    padding: '30px',
    margin: 0,
  },
  row: {
    flex: '1',
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'stretch',
    minWidth: 0,
    minHeight: 0,
    // overflow: 'hidden',
    position: 'relative',
  },
}))(App)
