import { Text, View } from "react-native"

import colors from "../../colors"
import textStyles from "../../textStyles"

class Button extends React.Component {
  render() {
    let View$onPress;
    let View$backgroundColor;
    let Text$text;
    Text$text = this.props.label
    View$onPress = this.props.onTap
    if (View$hovered) {
      View$backgroundColor = "blue200"
    }
    if (View$pressed) {
      View$backgroundColor = "blue50"
    }
    return (
      <View
        style={[ styles.View, { onPress: View$onPress } ]}
        backgroundColor={View$backgroundColor}
      >
        <Text style={[ styles.Text, {} ]} text={Text$text}>

        </Text>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  View: {
    paddingBottom: 12,
    paddingLeft: 16,
    paddingRight: 16,
    paddingTop: 12
  },
  Text: { font: "button" }
});