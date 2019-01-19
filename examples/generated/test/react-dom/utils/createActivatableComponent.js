import { React } from "react";

export default function createActivatableComponent(WrappedComponent) {
  class Wrapper extends React.Component {
    _handleKeyDown = event => {
      if (event.key === "Enter") {
        this.props.onAccessibilityActivate &&
          this.props.onAccessibilityActivate();

        event.stopPropagation();
        event.preventDefault();
      } else {
        this.props.onKeyDown && this.props.onKeyDown(event);
      }
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
