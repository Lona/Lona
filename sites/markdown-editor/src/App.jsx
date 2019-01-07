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

let initialValue = 'oiawhdoahw';
let initialEditableValue = true;
let onChangeValue = () => {};
let onChangeEditableValue = () => {};

window.update = ({ type, payload }) => {
  switch (type) {
    case 'setDescription':
      initialValue = payload;
      return onChangeValue(payload);
    case 'setEditable':
      initialEditableValue = payload;
      return onChangeEditableValue(payload);
    default:
      break;
  }
};

sendNotification({ type: 'ready' });

class App extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      value: initialValue,
      editable: initialEditableValue
    };

    this.handleChange = this.handleChange.bind(this);

    onChangeValue = value => {
      this.setState({ value });
    };
    onChangeEditableValue = editable => {
      this.setState({ editable });
    };
  }

  handleChange(code) {
    this.setState({ value: code });
    sendNotification({ type: 'description', payload: code });
  }

  render() {
    const { styles, css } = this.props;
    const { value, editable } = this.state;

    const markdownCss = { ...css(styles.column) };
    markdownCss.className += ' markdown-body';

    return (
      <div {...css(styles.row)}>
        <ReactMarkdown {...markdownCss} source={value} escapeHtml={false} />
        {editable
          ? <Editor
              value={value}
              filename={'README.md'}
              onChange={this.handleChange}
              errorLineNumber={false}
            />
          : null}
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
