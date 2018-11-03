import React from "react"
import { Text, Image, View, StyleSheet, TextStyles } from
  "@mathieudutour/react-sketchapp"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class TextAlignment extends React.Component {
  render() {


    return (
      <View style={styles.view}>
        <View style={styles.view1}>
          <Image
            style={styles.image}
            source={require("../assets/icon_128x128.png")}

          />
          <View style={styles.view2} />
          <Text style={styles.text} numberOfLines={2}>
            {"Welcome to Lona Studio"}
          </Text>
          <Text style={styles.text1}>
            {"Centered - Width: Fit"}
          </Text>
          <Text style={styles.text2}>
            {"Left aligned - Width: Fill"}
          </Text>
          <Text style={styles.text3}>
            {"Right aligned - Width: Fill"}
          </Text>
          <Text style={styles.text4}>
            {"Centered - Width: 80"}
          </Text>
        </View>
        <View style={styles.view3}>
          <Text style={styles.text5}>
            {"Left aligned text, Fit w/ secondary centering"}
          </Text>
        </View>
        <View style={styles.view4}>
          <Text style={styles.text6}>
            {"Left aligned text, Fixed w/ secondary centering"}
          </Text>
        </View>
        <View style={styles.view5}>
          <Text style={styles.text7}>
            {"Centered text, Fit parent no centering"}
          </Text>
        </View>
        <View style={styles.view6}>
          <Text style={styles.text8}>
            {"Centered text, Fixed parent no centering"}
          </Text>
        </View>
        <View style={styles.rightAlignmentContainer}>
          <Text style={styles.text9}>
            {"Fit Text"}
          </Text>
          <Text style={styles.text10}>
            {"Fill and center aligned text"}
          </Text>
          <Image
            style={styles.image1}
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
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingTop: 10,
    paddingRight: 10,
    paddingBottom: 10,
    paddingLeft: 10
  },
  view1: {
    alignItems: "center",
    alignSelf: "stretch",
    backgroundColor: colors.indigo50,
    flex: 0,
    flexDirection: "column",
    justifyContent: "center"
  },
  view3: {
    alignItems: "center",
    backgroundColor: "#D8D8D8",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingRight: 12,
    paddingLeft: 12
  },
  view4: {
    alignItems: "center",
    backgroundColor: "#D8D8D8",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingRight: 12,
    paddingLeft: 12,
    width: 400
  },
  view5: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingRight: 12,
    paddingLeft: 12
  },
  view6: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingRight: 12,
    paddingLeft: 12,
    width: 400
  },
  rightAlignmentContainer: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    backgroundColor: "#D8D8D8",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  image: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 100,
    height: 100,
    resizeMode: "cover"
  },
  view2: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text: {
    textAlign: "center",
    ...TextStyles.get("display1"),
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start",
    marginTop: 16
  },
  text1: {
    textAlign: "center",
    ...TextStyles.get("subheading2"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start",
    marginTop: 16
  },
  text2: {
    ...TextStyles.get("body1"),
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start",
    marginTop: 12
  },
  text3: {
    textAlign: "right",
    ...TextStyles.get("body1"),
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text4: {
    textAlign: "center",
    ...TextStyles.get("body1"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 80
  },
  text5: {
    ...TextStyles.get("body1"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text6: {
    ...TextStyles.get("body1"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text7: {
    textAlign: "center",
    ...TextStyles.get("body1"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text8: {
    textAlign: "center",
    ...TextStyles.get("body1"),
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text9: {
    ...TextStyles.get("body1"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text10: {
    textAlign: "center",
    ...TextStyles.get("body1"),
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  image1: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 100,
    height: 100,
    resizeMode: "cover"
  }
})