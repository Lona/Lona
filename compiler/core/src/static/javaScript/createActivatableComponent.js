import React from "react";

export default function createActivatableComponent(WrappedComponent) {
  class Wrapper extends React.Component {
    _handleKeyDown = event => {
      const { onAccessibilityActivate, onKeyDown } = this.props;

      if (event.key === "Enter") {
        onAccessibilityActivate && onAccessibilityActivate();

        event.stopPropagation();
        event.preventDefault();

        return;
      }

      onKeyDown && onKeyDown(event);
    };

    render() {
      const { forwardedRef, onAccessibilityActivate, ...rest } = this.props;

      return (
        <WrappedComponent
          ref={forwardedRef}
          {...rest}
          onKeyDown={this._handleKeyDown}
        />
      );
    }
  }

  return React.forwardRef((props, ref) => {
    return <Wrapper {...props} forwardedRef={ref} />;
  });
}
