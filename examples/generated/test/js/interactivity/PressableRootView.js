class PressableRootView extends React.Component {
  render() {
    let Inner$onPress;
    let Inner$backgroundColor;
    let InnerText$text;
    let Button$onPress;
    let Button$backgroundColor;
    Button$onPress = this.props.onPressButton
    Inner$onPress = this.props.onPressInner
    if (Button$hovered) {
      Button$backgroundColor = "grey100"
    }
    if (Button$pressed) {
      Button$backgroundColor = "grey300"
    }
    if (Inner$hovered) {
      Inner$backgroundColor = "blue300"
      InnerText$text = "Hovered"
    }
    if (Inner$pressed) {
      Inner$backgroundColor = "blue800"
      InnerText$text = "Pressed"
    }
    if (Inner$hovered) {
      if (Inner$pressed) {
        InnerText$text = "Hovered & Pressed"
      }
    }
    return (
      <View
        style={[ styles.Button, { onPress: Button$onPress } ]}
        backgroundColor={Button$backgroundColor}
      >
        <View
          style={[ styles.Inner, { onPress: Inner$onPress } ]}
          backgroundColor={Inner$backgroundColor}
        >
          <Text style={[ styles.InnerText, {} ]} text={InnerText$text}>

          </Text>
        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  Button: {
    alignSelf: "stretch",
    flex: 0,
    paddingBottom: 24,
    paddingLeft: 24,
    paddingRight: 24,
    paddingTop: 24
  },
  Inner: { height: 100, width: 100 },
  InnerText: { font: "headline" }
});