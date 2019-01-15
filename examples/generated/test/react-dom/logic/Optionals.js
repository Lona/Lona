import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class Optionals extends React.Component {
  render() {


    let Label$text
    let StringParam$text
    let View$backgroundColor
    let unwrapped
    Label$text = ""
    StringParam$text = "No string param"
    View$backgroundColor = "transparent"

    if (this.props.boolParam == true) {

      Label$text = "boolParam is true"
      View$backgroundColor = colors.green200
    }
    if (this.props.boolParam == false) {

      Label$text = "boolParam is false"
      View$backgroundColor = colors.red200
    }
    if (this.props.boolParam == null) {

      Label$text = "boolParam is null"
    }
    if (this.props.stringParam != null) {

      let unwrapped = this.props.stringParam

      StringParam$text = unwrapped
    }
    return (
      <View style={{ backgroundColor: View$backgroundColor }}>
        <Label>
          {Label$text}
        </Label>
        <StringParam>
          {StringParam$text}
        </StringParam>
      </View>
    );
  }
};

let View = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Label = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let StringParam = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})