import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class TextAlignment extends React.Component {
  render() {


    return (
      <View>
        <View1>
          <Image src={require("../assets/icon_128x128.png")} />
          <View2 />
          <Text>
            {"Welcome to Lona Studio"}
          </Text>
          <Text1>
            {"Centered - Width: Fit"}
          </Text1>
          <Text2>
            {"Left aligned - Width: Fill"}
          </Text2>
          <Text3>
            {"Right aligned - Width: Fill"}
          </Text3>
          <Text4>
            {"Centered - Width: 80"}
          </Text4>
        </View1>
        <View3>
          <Text5>
            {"Left aligned text, Fit w/ secondary centering"}
          </Text5>
        </View3>
        <View4>
          <Text6>
            {"Left aligned text, Fixed w/ secondary centering"}
          </Text6>
        </View4>
        <View5>
          <Text7>
            {"Centered text, Fit parent no centering"}
          </Text7>
        </View5>
        <View6>
          <Text8>
            {"Centered text, Fixed parent no centering"}
          </Text8>
        </View6>
        <RightAlignmentContainer>
          <Text9>
            {"Fit Text"}
          </Text9>
          <Text10>
            {"Fill and center aligned text"}
          </Text10>
          <Image1 src={require("../assets/icon_128x128.png")} />
        </RightAlignmentContainer>
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
  paddingTop: "10px",
  paddingRight: "10px",
  paddingBottom: "10px",
  paddingLeft: "10px"
})

let View1 = styled.div({
  alignItems: "center",
  alignSelf: "stretch",
  backgroundColor: colors.indigo50,
  display: "flex",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "center"
})

let Image = styled.img({
  alignItems: "flex-start",
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  overflow: "hidden",
  width: "100px",
  height: "100px",
  objectFit: "cover",
  position: "relative"
})

let View2 = styled.div({
  alignItems: "flex-start",
  backgroundColor: "#D8D8D8",
  display: "flex",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Text = styled.span({
  textAlign: "center",
  ...textStyles.display1,
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start",
  marginTop: "16px",
  overflow: "hidden",
  maxHeight: "80px"
})

let Text1 = styled.span({
  textAlign: "center",
  ...textStyles.subheading2,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start",
  marginTop: "16px"
})

let Text2 = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start",
  marginTop: "12px"
})

let Text3 = styled.span({
  textAlign: "right",
  ...textStyles.body1,
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Text4 = styled.span({
  textAlign: "center",
  ...textStyles.body1,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start",
  width: "80px"
})

let View3 = styled.div({
  alignItems: "center",
  backgroundColor: "#D8D8D8",
  display: "flex",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start",
  paddingRight: "12px",
  paddingLeft: "12px"
})

let Text5 = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let View4 = styled.div({
  alignItems: "center",
  backgroundColor: "#D8D8D8",
  display: "flex",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start",
  paddingRight: "12px",
  paddingLeft: "12px",
  width: "400px"
})

let Text6 = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let View5 = styled.div({
  alignItems: "flex-start",
  backgroundColor: "#D8D8D8",
  display: "flex",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start",
  paddingRight: "12px",
  paddingLeft: "12px"
})

let Text7 = styled.span({
  textAlign: "center",
  ...textStyles.body1,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let View6 = styled.div({
  alignItems: "flex-start",
  backgroundColor: "#D8D8D8",
  display: "flex",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start",
  paddingRight: "12px",
  paddingLeft: "12px",
  width: "400px"
})

let Text8 = styled.span({
  textAlign: "center",
  ...textStyles.body1,
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let RightAlignmentContainer = styled.div({
  alignItems: "flex-end",
  alignSelf: "stretch",
  backgroundColor: "#D8D8D8",
  display: "flex",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Text9 = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Text10 = styled.span({
  textAlign: "center",
  ...textStyles.body1,
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Image1 = styled.img({
  alignItems: "flex-start",
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  overflow: "hidden",
  width: "100px",
  height: "100px",
  objectFit: "cover",
  position: "relative"
})