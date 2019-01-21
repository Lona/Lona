import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import ComponentParameterTemplate from "./ComponentParameterTemplate"

export default class ComponentParameterInstance extends React.Component {
  render() {



    return (
      <View>
        <ComponentParameterTemplateComponentParameterTemplateWrapper>
          <ComponentParameterTemplate
            subtitleComponent={{"parameters":{"text":"Subtitle","textStyle":"subheading2"},"type":"Lona:Text"}}
            titleComponent={{"parameters":{"text":"Title","textStyle":"headline"},"type":"Lona:Text"}}

          />
        </ComponentParameterTemplateComponentParameterTemplateWrapper>
      </View>
    );
  }
};

let View = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let ComponentParameterTemplateComponentParameterTemplateWrapper = styled.div({
  alignItems: "flex-start",
  alignSelf: "stretch",
  display: "flex",
  flex: "1 1 auto",
  flexDirection: "row",
  justifyContent: "flex-start"
})