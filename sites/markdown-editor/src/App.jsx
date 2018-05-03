import React from 'react';
import { withStyles } from 'react-with-styles';
import ReactMarkdown from 'react-markdown';

import Editor from './components/Editor';

class App extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      value: '',
    };

    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(code) {
    try {
      this.setState({ value: code });
      window.webkit.messageHandlers.notification.postMessage({ payload: code });
    } catch (e) {
      console.log('No webkit messageHandlers', e);
    }
  }

  render() {
    const { styles, css } = this.props;
    const { value } = this.state;

    const markdownCss = { ...css(styles.column) };
    markdownCss.className += ' markdown-body';

    return (
      <div {...css(styles.row)}>
        <Editor
          initialValue={''}
          filename={'README.md'}
          onChange={this.handleChange}
          errorLineNumber={false}
        />
        <ReactMarkdown {...markdownCss} source={value} />
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
    overflow: 'hidden',
    position: 'relative',
  },
  row: {
    flex: '1',
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'stretch',
    minWidth: 0,
    minHeight: 0,
    overflow: 'hidden',
    position: 'relative',
  },
}))(App);
