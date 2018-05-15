import React from "react"
import { Text, Image, View, StyleSheet } from "react-native"

import colors from "../colors"
import textStyles from "../textStyles"

export default class TextAlignment extends React.Component {
  render() {
    return (
      <View style={[ styles.view, {} ]}>
        <View style={[ styles.view1, {} ]}>
          <Image
            style={[ styles.image, {} ]}
            image={"file://./assets/icon_128x128.png"}
          >

          </Image>
          <View style={[ styles.view2, {} ]}>

          </View>
          <Text style={[ styles.text, {} ]} text={"Welcome to Lona Studio"}>
            {"Welcome to Lona Studio"}
          </Text>
          <Text style={[ styles.text1, {} ]} text={"Centered - Width: Fit"}>
            {"Centered - Width: Fit"}
          </Text>
          <Text
            style={[ styles.text2, {} ]}
            text={"Left aligned - Width: Fill"}
          >
            {"Left aligned - Width: Fill"}
          </Text>
          <Text
            style={[ styles.text3, {} ]}
            text={"Right aligned - Width: Fill"}
          >
            {"Right aligned - Width: Fill"}
          </Text>
          <Text style={[ styles.text4, {} ]} text={"Centered - Width: 80"}>
            {"Centered - Width: 80"}
          </Text>
        </View>
        <View style={[ styles.view3, {} ]}>
          <Text
            style={[ styles.text5, {} ]}
            text={"Left aligned text, Fit w/ secondary centering"}
          >
            {"Left aligned text, Fit w/ secondary centering"}
          </Text>
        </View>
        <View style={[ styles.view4, {} ]}>
          <Text
            style={[ styles.text6, {} ]}
            text={"Left aligned text, Fixed w/ secondary centering"}
          >
            {"Left aligned text, Fixed w/ secondary centering"}
          </Text>
        </View>
        <View style={[ styles.view5, {} ]}>
          <Text
            style={[ styles.text7, {} ]}
            text={"Centered text, Fit parent no centering"}
          >
            {"Centered text, Fit parent no centering"}
          </Text>
        </View>
        <View style={[ styles.view6, {} ]}>
          <Text
            style={[ styles.text8, {} ]}
            text={"Centered text, Fixed parent no centering"}
          >
            {"Centered text, Fixed parent no centering"}
          </Text>
        </View>
        <View style={[ styles.rightAlignmentContainer, {} ]}>
          <Text style={[ styles.text9, {} ]} text={"Fit Text"}>
            {"Fit Text"}
          </Text>
          <Text
            style={[ styles.text10, {} ]}
            text={"Fill and center aligned text"}
          >
            {"Fill and center aligned text"}
          </Text>
          <Image
            style={[ styles.image1, {} ]}
            image={"file://./assets/icon_128x128.png"}
          >

          </Image>
        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    paddingBottom: 10,
    paddingLeft: 10,
    paddingRight: 10,
    paddingTop: 10
  },
  view1: {
    alignItems: "center",
    alignSelf: "stretch",
    backgroundColor: colors.indigo50,
    justifyContent: "center"
  },
  image: { height: 100, width: 100 },
  view2: { backgroundColor: "#D8D8D8" },
  text: { alignSelf: "stretch", marginTop: 16, textAlign: "center" },
  text1: { marginTop: 16, textAlign: "center" },
  text2: { alignSelf: "stretch", marginTop: 12 },
  text3: { alignSelf: "stretch", textAlign: "right" },
  text4: { textAlign: "center", width: 80 },
  view3: {
    alignItems: "center",
    backgroundColor: "#D8D8D8",
    paddingLeft: 12,
    paddingRight: 12
  },
  text5: {},
  view4: {
    alignItems: "center",
    backgroundColor: "#D8D8D8",
    paddingLeft: 12,
    paddingRight: 12,
    width: 400
  },
  text6: {},
  view5: { backgroundColor: "#D8D8D8", paddingLeft: 12, paddingRight: 12 },
  text7: { textAlign: "center" },
  view6: {
    backgroundColor: "#D8D8D8",
    paddingLeft: 12,
    paddingRight: 12,
    width: 400
  },
  text8: { alignSelf: "stretch", textAlign: "center" },
  rightAlignmentContainer: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    backgroundColor: "#D8D8D8"
  },
  text9: {},
  text10: { alignSelf: "stretch", textAlign: "center" },
  image1: { height: 100, width: 100 }
});