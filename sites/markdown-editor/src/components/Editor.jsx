// BSD License
//
// Copyright (c) 2016-present, Devin Abbott. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  * Neither the name Facebook nor the names of its contributors may be used to
//    endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
// ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// Adapted from react-native-web-player

import React from 'react';

import { options, requireAddons } from '../utils/CodeMirror';

require('codemirror/lib/codemirror.css');
require('codemirror/addon/hint/show-hint.css');
require('../styles/codemirror-theme.css');

// Work around a codemirror + flexbox + chrome issue by creating an absolute
// positioned parent and flex grandparent of the codemirror element.
// https://github.com/jlongster/debugger.html/issues/63
const styles = {
  editorContainer: {
    display: 'flex',
    position: 'relative',
    flex: '1',
    minWidth: 0,
    minHeight: 0,
  },
  editor: {
    position: 'absolute',
    height: '100%',
    width: '100%',
  },
};

const docCache = {};

const defaultProps = {
  initialValue: null,
  value: null,
  onChange: () => {},
  readOnly: false,
};

// From https://github.com/decosoftware/deco-ide/blob/5cede568614a1a70b3118870d48b371af54a3cf9/web/src/scripts/utils/editor/ChangeUtils.js
// Return true if these changes are from user input
export const containsUserInputChange = changes => {
  const origin = changes[changes.length - 1].origin;

  // http://stackoverflow.com/questions/26174164/auto-complete-with-codemirrror
  return origin === '+input' || origin === '+delete';
};

class Editor extends React.Component {
  componentDidMount() {
    if (typeof navigator !== 'undefined') {
      const { filename, initialValue, value, readOnly, onChange } = this.props;

      requireAddons();
      const CodeMirror = require('codemirror');

      if (!docCache[filename]) {
        docCache[filename] = new CodeMirror.Doc(
          initialValue || value || '',
          options.mode,
        );
      }

      this.cm = CodeMirror(this.editor, {
        ...options,
        readOnly,

        value: docCache[filename].linkedDoc({ sharedHist: true }),
      });

      // TODO: Probably we can remove this and setTimeout by fixing the css/styles
      this.cm.setSize('100%', '100%');
      setTimeout(() => {
        this.cm.refresh();
      }, 0);

      this.cm.on('changes', (cm, changes) => {
        onChange(cm.getValue());

        const { completions } = this.props;

        if (!completions || completions.length === 0) return;

        if (!containsUserInputChange(changes)) return;

        const range = cm.listSelections()[0];
        const from = range.from();

        if (!range.empty()) return;

        const textBefore = cm.getRange(new CodeMirror.Pos(from.line, 0), from);

        for (const completion of completions) {
          const { trigger, getList } = completion;

          // Show popup if the user has typed at least 1 characters
          const match = textBefore.match(trigger);

          if (!match) continue;

          const prefix = match[0];

          this.cm.showHint({
            hint: () => ({
              list: getList(match),
              from: new CodeMirror.Pos(from.line, from.ch - prefix.length),
              to: from,
            }),
            alignWithWord: false,
            completeSingle: false,
          });

          break;
        }
      });
    }
  }

  componentWillUpdate(nextProps) {
    const { errorLineNumber: nextLineNumber, value } = nextProps;
    const { errorLineNumber: prevLineNumber } = this.props;

    if (this.cm) {
      if (typeof prevLineNumber === 'number') {
        this.cm.removeLineClass(prevLineNumber, 'background', 'cm-line-error');
      }

      if (typeof nextLineNumber === 'number') {
        this.cm.addLineClass(nextLineNumber, 'background', 'cm-line-error');
      }

      if (typeof value === 'string' && value !== this.cm.getValue()) {
        this.cm.setValue(value);
      }
    }
  }

  componentWillUnmount() {
    if (typeof navigator !== 'undefined') {
      const { filename } = this.props;
      const CodeMirror = require('codemirror');

      // Store a reference to the current linked doc
      const linkedDoc = this.cm.doc;

      this.cm.swapDoc(new CodeMirror.Doc('', options.mode));

      // Unlink the doc
      docCache[filename].unlinkDoc(linkedDoc);
    }
  }

  render() {
    const { readOnly } = this.props;

    return (
      <div
        style={styles.editorContainer}
        className={readOnly ? 'read-only' : undefined}
      >
        <div
          style={styles.editor}
          ref={ref => {
            this.editor = ref;
          }}
        />
      </div>
    );
  }
}

Editor.defaultProps = defaultProps;

export default Editor;
