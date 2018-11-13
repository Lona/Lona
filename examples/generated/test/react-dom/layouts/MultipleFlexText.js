import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class MultipleFlexText extends React.Component {
  render() {


    return (
      <View>
        <View1>
          <View3>
            <Text>
              {"Some long text (currently LS lays out incorrectly)"}
            </Text>
          </View3>
        </View1>
        <View2>
          <View4>
            <Text1>
              {"Short"}
            </Text1>
          </View4>
        </View2>
      </View>
    );
  }
};

let View = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "row",
  justifyContent: "flex-start"
})

let View1 = styled.div({
  alignItems: "flex-start",
  backgroundColor: colors.red50,
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start",
  height: "100px"
})

let View3 = styled.div({
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Text = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let View2 = styled.div({
  alignItems: "flex-start",
  backgroundColor: colors.blue50,
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start",
  height: "100px"
})

let View4 = styled.div({
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Text1 = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})