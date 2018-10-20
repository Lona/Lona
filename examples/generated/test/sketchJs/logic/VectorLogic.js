import React from "react"
import { View, StyleSheet, TextStyles, Svg } from
  "@mathieudutour/react-sketchapp"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

let CheckCircleVector = (props) => {
  return (
    <Svg style={props.style} viewBox={"0 0 24 24"}>
      <Svg.Path
        d={"M12,0L12,0C18.627416998,0 24,5.37258300203 24,12L24,12C24,18.627416998 18.627416998,24 12,24L12,24C5.37258300203,24 0,18.627416998 0,12L0,12C0,5.37258300203 5.37258300203,0 12,0Z"}
        fill={props.g0_circle0Fill || "#00C121"}

      />
      <Svg.Path
        d={"M6.5,12.6L9.75,15.85L17.25,8.35"}
        fill={"none"}
        stroke={props.g0_polyline1Stroke || "#FFFFFF"}
        strokeWidth={"2"}
        strokeLinecap={"round"}

      />
    </Svg>
  );
}

export default class VectorLogic extends React.Component {
  render() {

    let Check$vector$g0_circle0$fill
    let Check$vector$g0_polyline1$stroke

    if (this.props.active === false) {
      Check$vector$g0_circle0$fill = colors.grey300
    }
    if (this.props.active) {
      Check$vector$g0_circle0$fill = colors.green400
      Check$vector$g0_polyline1$stroke = colors.green100
    }
    return (
      <View style={styles.view}>
        <CheckCircleVector
          style={styles.check}
          g0_circle0Fill={Check$vector$g0_circle0$fill}
          g0_polyline1Stroke={Check$vector$g0_polyline1$stroke}

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
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  check: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 100,
    height: 100
  }
})