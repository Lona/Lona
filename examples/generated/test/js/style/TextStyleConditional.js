import { Text, View } from "react-native"

import colors from "../../colors"
import textStyles from "../../textStyles"

class TextStyleConditional extends React.Component {
  render() {
    let Text$textStyle;
    if (this.props.large) {
      Text$textStyle = "display2"
    }
    return (
      <View style={[ styles.View, {} ]}>
        <Text
          style={[ styles.Text, {} ]}
          text={"Text goes here"}
          textStyle={Text$textStyle}
        >

        </Text>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  View: { alignSelf: "stretch" },
  Text: { font: "headline" }
});