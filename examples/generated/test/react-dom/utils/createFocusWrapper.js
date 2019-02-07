import React from "react";

// Track the previous document.activeElement to determine where to move focus next
const documentFocusListeners = [];
let previousActiveElement = null;
let activeElement = null;

document.addEventListener("focus", handleDocumentFocus, true);

function handleDocumentFocus(e) {
  previousActiveElement = activeElement;
  activeElement = e.target;

  documentFocusListeners.forEach(listener => listener(e));
}

function compareNodePosition(a, b) {
  if (!a || !b) return "none";

  const documentPosition = a.compareDocumentPosition(b);

  if (documentPosition & Node.DOCUMENT_POSITION_CONTAINS) return "contains";
  if (documentPosition & Node.DOCUMENT_POSITION_CONTAINED_BY)
    return "contained_by";
  if (documentPosition & Node.DOCUMENT_POSITION_PRECEDING) return "preceding";
  if (documentPosition & Node.DOCUMENT_POSITION_FOLLOWING) return "following";

  return "none";
}

export default function createFocusWrapper(WrappedComponent) {
  return class FocusWrapper extends React.Component {
    state = {
      tabIndex: 0
    };

    componentDidMount() {
      documentFocusListeners.push(this._handleDocumentFocus);
    }

    componentWillUnmount() {
      const index = documentFocusListeners.indexOf(this._handleDocumentFocus);
      if (index > -1) {
        documentFocusListeners.splice(index, 1);
      }
    }

    _backupRef = React.createRef();

    // We always need a ref. If we don't receive one as a prop, use the backup.
    _getRef() {
      const { forwardedRef } = this.props;

      return forwardedRef || this._backupRef;
    }

    _handleDocumentFocus = e => {
      const ref = this._getRef();

      if (ref.current) {
        this.setState({
          // Use a tabIndex of -1 to prevent focus from returning to the wrapper
          // when the focus is already on a descendant element.
          tabIndex: ref.current.contains(e.target) ? -1 : 0
        });
      }
    };

    _handleFocus = e => {
      const { onFocusFirst, onFocusLast, onFocus } = this.props;

      const ref = this._getRef();

      if (e.target === ref.current) {
        const position = compareNodePosition(
          document.activeElement,
          previousActiveElement
        );

        switch (position) {
          case "preceding":
          case "none":
            onFocusFirst && onFocusFirst();

            e.stopPropagation();
            e.preventDefault();
            break;
          case "following":
            onFocusLast && onFocusLast();

            e.stopPropagation();
            e.preventDefault();
            break;
          case "contains":
          case "contained_by":
          default:
            break;
        }
      } else {
        onFocus && onFocus();
      }
    };

    render() {
      const { forwardedRef, onFocusFirst, onFocusLast, ...rest } = this.props;
      const { tabIndex } = this.state;

      return (
        <WrappedComponent
          {...rest}
          tabIndex={tabIndex}
          ref={this._getRef()}
          onFocus={this._handleFocus}
        />
      );
    }
  };
}
