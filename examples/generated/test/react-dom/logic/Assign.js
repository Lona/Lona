import React from "react"

import colors from "../colors"
import textStyles from "../textStyles"

export default class Assign extends React.Component {
  render() {

    let Text$text

    Text$text = this.props.text
    return (
      <div style={Object.assign(styles.view, {})}>
        <span style={Object.assign(styles.text, {})}>
          {Text$text}
        </span>
      </div>
    );
  }
};

let styles = {
  view: { alignSelf: "stretch", display: "flex" },
  text: { display: "flex" }
}