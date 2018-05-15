import { View } from "react-native"

import colors from "../../colors"
import textStyles from "../../textStyles"

class BorderWidthColor extends React.Component {
  render() {
    return (
      <View style={[ styles.View, {} ]}>
        <View
          style={[ styles.View 1, {} ]}
          borderColor={"blue300"}
          borderRadius={10}
          borderWidth={20}
        >

        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  View: { alignSelf: "stretch" },
  View 1: { height: 100, width: 100 }
});