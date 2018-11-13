import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class TextStyleConditional extends React.Component {
  render() {

    let Text$textStyle
    Text$textStyle = textStyles.headline

    if (this.props.large) {
      Text$textStyle = textStyles.display2
    }
    return (
      <View>
        <Text style={{ ...Text$textStyle }}>
          {"Text goes here"}
        </Text>
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

let Text = styled.span({
  textAlign: "left",
  ...textStyles.headline,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})