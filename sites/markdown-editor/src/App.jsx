import React from 'react';
import { withStyles } from 'react-with-styles';
import ReactMarkdown from 'react-markdown';

import Editor from './components/Editor';

function sendNotification(notification) {
  try {
    window.webkit.messageHandlers.notification.postMessage(notification);
  } catch (e) {
    console.log('No webkit messageHandlers', e);
  }
}

let initialValue = '';
let onChangeValue = () => {};

window.update = ({ type, payload }) => {
  switch (type) {
    case 'setDescription':
      initialValue = payload;
      return onChangeValue(payload);
    default:
      break;
  }
};

sendNotification({ type: 'ready' });

class App extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      value: initialValue
    };

    this.handleChange = this.handleChange.bind(this);

    onChangeValue = value => {
      this.setState({ value });
    };
  }

  handleChange(code) {
    this.setState({ value: code });
    sendNotification({ type: 'description', payload: code });
  }

  render() {
    const { styles, css } = this.props;
    const { value } = this.state;

    const markdownCss = { ...css(styles.column) };
    markdownCss.className += ' markdown-body';

    return (
      <div {...css(styles.row)}>
        <ReactMarkdown {...markdownCss} source={value} escapeHtml={false} />
        {typeof EDITABLE !== 'undefined' && !EDITABLE
          ? null
          : <Editor
              value={value}
              filename={'README.md'}
              onChange={this.handleChange}
              errorLineNumber={false}
            />}
      </div>
    );
  }
}

export default withStyles(() => ({
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
    color: typeof THEME !== 'undefined' ? THEME.text : undefined
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
}))(App);
