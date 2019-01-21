import React from "react"
import { Image, Text, View, StyleSheet, TextStyles } from
  "@mathieudutour/react-sketchapp"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class AccessibilityTest extends React.Component {
  render() {

    let AccessibleText$accessibilityLabel
    let CheckboxCircle$visible
    let CheckboxRow$accessibilityValue
    let CheckboxRow$onAccessibilityActivate
    let Checkbox$onPress
    CheckboxCircle$visible = true
    CheckboxRow$accessibilityValue = ""

    AccessibleText$accessibilityLabel = this.props.customTextAccessibilityLabel
    if (this.props.checkboxValue) {
      CheckboxCircle$visible = true
      CheckboxRow$accessibilityValue = "checked"
    }
    if (this.props.checkboxValue === false) {
      CheckboxCircle$visible = false
      CheckboxRow$accessibilityValue = "unchecked"
    }
    CheckboxRow$onAccessibilityActivate = this.props.onToggleCheckbox
    Checkbox$onPress = this.props.onToggleCheckbox
    return (
      <View style={styles.view}>
        <View style={styles.checkboxRow}>
          <View style={styles.checkbox} onPress={Checkbox$onPress}>
            {CheckboxCircle$visible && <View style={styles.checkboxCircle} />}
          </View>
          <Text style={styles.text}>
            {"Checkbox description"}
          </Text>
        </View>
        <View style={styles.row1}>
          <View style={styles.element}>
            <View style={styles.inner} />
          </View>
          <View style={styles.container}>
            <Image
              style={styles.image}
              source={require("../assets/icon_128x128.png")}

            />
            <Text style={styles.accessibleText}>
              {"Greetings"}
            </Text>
          </View>
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
    justifyContent: "flex-start"
  },
  checkboxRow: {
    alignItems: "center",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "row",
    justifyContent: "flex-start",
    paddingTop: 10,
    paddingRight: 10,
    paddingBottom: 10,
    paddingLeft: 10
  },
  row1: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "row",
    justifyContent: "flex-start",
    paddingTop: 10,
    paddingRight: 10,
    paddingBottom: 10,
    paddingLeft: 10
  },
  checkbox: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    marginRight: 10,
    paddingTop: 4,
    paddingRight: 4,
    paddingBottom: 4,
    paddingLeft: 4,
    borderColor: colors.grey400,
    borderRadius: 20,
    borderStyle: "solid",
    borderWidth: 1,
    width: 30,
    height: 30
  },
  text: {
    ...TextStyles.get("body1"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  checkboxCircle: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    backgroundColor: colors.green200,
    flex: 1,
    flexDirection: "column",
    justifyContent: "flex-start",
    borderRadius: 15
  },
  element: {
    alignItems: "flex-start",
    backgroundColor: colors.red600,
    flexDirection: "column",
    justifyContent: "flex-start",
    marginRight: 10,
    paddingTop: 10,
    paddingRight: 10,
    paddingBottom: 10,
    paddingLeft: 10,
    width: 50,
    height: 50
  },
  container: {
    alignItems: "center",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  inner: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    backgroundColor: colors.red800,
    flex: 1,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  image: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    marginRight: 4,
    width: 50,
    height: 50,
    resizeMode: "cover"
  },
  accessibleText: {
    ...TextStyles.get("body1"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  imageResizeModeCover: {
    width: "100%",
    height: "100%",
    resizeMode: "cover",
    position: "absolute"
  }
})