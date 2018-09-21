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
            source={require("../assets/icon_128x128.png")}

          />
          <View style={[ styles.view2, {} ]} />
          <Text style={[ styles.text, {} ]}>
            {"Welcome to Lona Studio"}
          </Text>
          <Text style={[ styles.text1, {} ]}>
            {"Centered - Width: Fit"}
          </Text>
          <Text style={[ styles.text2, {} ]}>
            {"Left aligned - Width: Fill"}
          </Text>
          <Text style={[ styles.text3, {} ]}>
            {"Right aligned - Width: Fill"}
          </Text>
          <Text style={[ styles.text4, {} ]}>
            {"Centered - Width: 80"}
          </Text>
        </View>
        <View style={[ styles.view3, {} ]}>
          <Text style={[ styles.text5, {} ]}>
            {"Left aligned text, Fit w/ secondary centering"}
          </Text>
        </View>
        <View style={[ styles.view4, {} ]}>
          <Text style={[ styles.text6, {} ]}>
            {"Left aligned text, Fixed w/ secondary centering"}
          </Text>
        </View>
        <View style={[ styles.view5, {} ]}>
          <Text style={[ styles.text7, {} ]}>
            {"Centered text, Fit parent no centering"}
          </Text>
        </View>
        <View style={[ styles.view6, {} ]}>
          <Text style={[ styles.text8, {} ]}>
            {"Centered text, Fixed parent no centering"}
          </Text>
        </View>
        <View style={[ styles.rightAlignmentContainer, {} ]}>
          <Text style={[ styles.text9, {} ]}>
            {"Fit Text"}
          </Text>
          <Text style={[ styles.text10, {} ]}>
            {"Fill and center aligned text"}
          </Text>
          <Image
            style={[ styles.image1, {} ]}
            source={require("../assets/icon_128x128.png")}

          />
        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    paddingTop: 10,
    paddingRight: 10,
    paddingBottom: 10,
    paddingLeft: 10
  },
  view1: {
    alignItems: "center",
    alignSelf: "stretch",
    backgroundColor: colors.indigo50,
    justifyContent: "center"
  },
  image: { width: 100, height: 100 },
  view2: { backgroundColor: "#D8D8D8" },
  text: {
    textAlign: "center",
    ...textStyles.display1,
    alignSelf: "stretch",
    marginTop: 16
  },
  text1: { textAlign: "center", ...textStyles.subheading2, marginTop: 16 },
  text2: { alignSelf: "stretch", marginTop: 12 },
  text3: { textAlign: "right", alignSelf: "stretch" },
  text4: { textAlign: "center", width: 80 },
  view3: {
    alignItems: "center",
    backgroundColor: "#D8D8D8",
    paddingRight: 12,
    paddingLeft: 12
  },
  text5: {},
  view4: {
    alignItems: "center",
    backgroundColor: "#D8D8D8",
    paddingRight: 12,
    paddingLeft: 12,
    width: 400
  },
  text6: {},
  view5: { backgroundColor: "#D8D8D8", paddingRight: 12, paddingLeft: 12 },
  text7: { textAlign: "center" },
  view6: {
    backgroundColor: "#D8D8D8",
    paddingRight: 12,
    paddingLeft: 12,
    width: 400
  },
  text8: { textAlign: "center", alignSelf: "stretch" },
  rightAlignmentContainer: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    backgroundColor: "#D8D8D8"
  },
  text9: {},
  text10: { textAlign: "center", alignSelf: "stretch" },
  image1: { width: 100, height: 100 }
})