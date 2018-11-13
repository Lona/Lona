import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class PrimaryAxisFillSiblings extends React.Component {
  render() {


    return (
      <Container>
        <Horizontal>
          <LeftCard>
            <Image>
              <ImageResizeModeCover
                src={require("../assets/icon_128x128.png")}

              />
            </Image>
            <Title>
              {"Title"}
            </Title>
            <Subtitle>
              {"Subtitle"}
            </Subtitle>
          </LeftCard>
          <Spacer />
          <RightCard>
            <Image1>
              <ImageResizeModeCover
                src={require("../assets/icon_128x128.png")}

              />
            </Image1>
            <Title1>
              {"Title"}
            </Title1>
            <Subtitle1>
              {"Subtitle"}
            </Subtitle1>
          </RightCard>
        </Horizontal>
      </Container>
    );
  }
};

let ImageResizeModeCover = styled.img({
  width: "100%",
  height: "100%",
  objectFit: "cover",
  position: "absolute"
})

let Container = styled.div({
  alignItems: "flex-start",
  backgroundColor: colors.teal50,
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start",
  paddingTop: "10px",
  paddingRight: "10px",
  paddingBottom: "10px",
  paddingLeft: "10px"
})

let Horizontal = styled.div({
  alignItems: "flex-start",
  alignSelf: "stretch",
  backgroundColor: colors.teal100,
  display: "flex",
  flex: "0 0 auto",
  flexDirection: "row",
  justifyContent: "flex-start"
})

let LeftCard = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Image = styled.div({
  alignItems: "flex-start",
  alignSelf: "stretch",
  backgroundColor: colors.teal200,
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  overflow: "hidden",
  height: "100px",
  position: "relative"
})

let Title = styled.span({
  textAlign: "left",
  ...textStyles.body2,
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Subtitle = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Spacer = styled.div({
  alignItems: "flex-start",
  backgroundColor: "#D8D8D8",
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  width: "8px",
  height: "0px"
})

let RightCard = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Image1 = styled.div({
  alignItems: "flex-start",
  alignSelf: "stretch",
  backgroundColor: colors.teal200,
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  overflow: "hidden",
  height: "100px",
  position: "relative"
})

let Title1 = styled.span({
  textAlign: "left",
  ...textStyles.body2,
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Subtitle1 = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})