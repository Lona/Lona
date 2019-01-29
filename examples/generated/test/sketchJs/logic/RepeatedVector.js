import React from "react"
import { View, StyleSheet, TextStyles, Svg } from "react-sketchapp"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

let CheckCheckCircleVector = (props) => {
  return (
    <Svg
      style={props.style}
      preserveAspectRatio={props.preserveAspectRatio || "xMidYMid slice"}
      viewBox={"0 0 24 24"}
    >
      <Svg.Path
        d={"M12,0L12,0C18.627416998,0 24,5.37258300203 24,12L24,12C24,18.627416998 18.627416998,24 12,24L12,24C5.37258300203,24 0,18.627416998 0,12L0,12C0,5.37258300203 5.37258300203,0 12,0Z"}
        fill={props.ovalFill || "#00C121"}

      />
      <Svg.Path
        d={"M6.5,12.6L9.75,15.85L17.25,8.35"}
        fill={"none"}
        stroke={props.pathStroke || "#FFFFFF"}
        strokeWidth={"2"}
        strokeLinecap={"round"}

      />
    </Svg>
  );
}
let AnotherCheckCheckCircleVector = (props) => {
  return (
    <Svg
      style={props.style}
      preserveAspectRatio={props.preserveAspectRatio || "xMidYMid slice"}
      viewBox={"0 0 24 24"}
    >
      <Svg.Path
        d={"M12,0L12,0C18.627416998,0 24,5.37258300203 24,12L24,12C24,18.627416998 18.627416998,24 12,24L12,24C5.37258300203,24 0,18.627416998 0,12L0,12C0,5.37258300203 5.37258300203,0 12,0Z"}
        fill={props.ovalFill || "#00C121"}

      />
      <Svg.Path
        d={"M6.5,12.6L9.75,15.85L17.25,8.35"}
        fill={"none"}
        stroke={props.pathStroke || "#FFFFFF"}
        strokeWidth={"2"}
        strokeLinecap={"round"}

      />
    </Svg>
  );
}

export default class RepeatedVector extends React.Component {
  render() {

    let AnotherCheck$vector$path$stroke
    let Check$vector$oval$fill

    Check$vector$oval$fill = colors.grey300
    if (this.props.active) {
      Check$vector$oval$fill = colors.green400
    }
    AnotherCheck$vector$path$stroke = colors.green800
    return (
      <View style={styles.view}>
        <CheckCheckCircleVector
          style={styles.check}
          ovalFill={Check$vector$oval$fill}
          preserveAspectRatio={"xMidYMid meet"}

        />
        <AnotherCheckCheckCircleVector
          style={styles.anotherCheck}
          pathStroke={AnotherCheck$vector$path$stroke}
          preserveAspectRatio={"xMidYMid meet"}

        />
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  check: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 100,
    height: 100,
    resizeMode: "contain"
  },
  anotherCheck: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 100,
    height: 100,
    resizeMode: "contain"
  }
})