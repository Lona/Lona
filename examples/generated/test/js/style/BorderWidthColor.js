import { View } from "react-native"

import colors from "../../colors"
import textStyles from "../../textStyles"

class BorderWidthColor extends React.Component {
  render() {
    return (
      <View style={[ styles.view, {} ]}>
        <View style={[ styles.view1, {} ]} borderRadius={10}>

        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: { alignSelf: "stretch" },
  view1: { borderColor: "blue300", borderWidth: 20, height: 100, width: 100 }
});