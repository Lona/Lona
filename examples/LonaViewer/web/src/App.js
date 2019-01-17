import React, { Component } from "react";
import "./App.css";

import AccessibilityTest from "./generated/interactivity/AccessibilityTest";

class App extends Component {
  state = {
    checked: false
  };

  handleKeyDown = event => {
    if (event.key === "Tab" && document.activeElement === document.body) {
      this.accessibilityTest.focus({ showFocusRing: true });

      event.stopPropagation();
      event.preventDefault();
    }
  };

  componentDidMount() {
    document.addEventListener("keydown", this.handleKeyDown);
  }

  componentWillUnmount() {
    document.removeEventListener("keydown", this.handleKeyDown);
  }

  render() {
    return (
      <div className="App">
        <AccessibilityTest
          ref={ref => {
            this.accessibilityTest = ref;
          }}
          checkboxValue={this.state.checked}
          onToggleCheckbox={() =>
            this.setState({ checked: !this.state.checked })
          }
        />
      </div>
    );
  }
}

export default App;
