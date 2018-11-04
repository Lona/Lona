import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

let CheckCircleVector = (props) => {
  return (
    <svg
      style={props.style}
      preserveAspectRatio={props.preserveAspectRatio || "xMidYMid slice"}
      viewBox={"0 0 24 24"}
    >
      <path
        d={"M12,0L12,0C18.627416998,0 24,5.37258300203 24,12L24,12C24,18.627416998 18.627416998,24 12,24L12,24C5.37258300203,24 0,18.627416998 0,12L0,12C0,5.37258300203 5.37258300203,0 12,0Z"}
        fill={props.ovalFill || "#00C121"}

      />
      <path
        d={"M6.5,12.6L9.75,15.85L17.25,8.35"}
        fill={"none"}
        stroke={props.pathStroke || "#FFFFFF"}
        strokeWidth={"2"}
        strokeLinecap={"round"}

      />
    </svg>
  );
}

export default class VectorLogic extends React.Component {
  render() {

    let Check$vector$oval$fill
    let Check$vector$path$stroke

    Check$vector$oval$fill = colors.grey300
    if (this.props.active) {
      Check$vector$oval$fill = colors.green400
      Check$vector$path$stroke = colors.green100
    }
    return (
      <div style={styles.view}>
        <CheckCircleVector
          style={styles.check}
          ovalFill={Check$vector$oval$fill}
          pathStroke={Check$vector$path$stroke}
          preserveAspectRatio={"xMidYMid meet"}

        />
      </div>
    );
  }
};

let styles = {
  view: {
    alignItems: "flex-start",
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  check: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "100px",
    height: "100px",
    objectFit: "contain"
  }
}