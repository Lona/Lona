import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class PrimaryAxis extends React.Component {
  render() {



    return (
      <View>
        <Fixed />
        <Fit>
          <Text>
            {"Text goes here"}
          </Text>
        </Fit>
        <Fill1 />
        <Fill2 />
      </View>
    );
  }
};

let View = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start",
  paddingTop: "24px",
  paddingRight: "24px",
  paddingBottom: "24px",
  paddingLeft: "24px",
  height: "500px"
})

let Fixed = styled.div({
  alignItems: "flex-start",
  backgroundColor: "#D8D8D8",
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  marginBottom: "24px",
  width: "100px",
  height: "100px"
})

let Fit = styled.div({
  alignItems: "flex-start",
  backgroundColor: "#D8D8D8",
  display: "flex",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start",
  marginBottom: "24px",
  width: "100px"
})

let Text = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Fill1 = styled.div({
  alignItems: "flex-start",
  backgroundColor: colors.cyan500,
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start",
  width: "100px"
})

let Fill2 = styled.div({
  alignItems: "flex-start",
  backgroundColor: colors.blue500,
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start",
  width: "100px"
})