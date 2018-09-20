type flexLayout('a) = {
  alignItems: 'a,
  alignSelf: 'a,
  display: 'a,
  justifyContent: 'a,
  flex: 'a,
  flexDirection: 'a,
  width: 'a,
  height: 'a
};

type edgeInsets('a) = {
  top: 'a,
  right: 'a,
  bottom: 'a,
  left: 'a
};

type layout('a) = {
  flex: flexLayout('a),
  padding: edgeInsets('a),
  margin: edgeInsets('a)
};

type border('a) = {
  borderRadius: 'a,
  borderWidth: 'a,
  borderColor: 'a
};

type textStyles('a) = {
  textAlign: 'a,
  textStyle: 'a
};

type viewLayerStyles('a) = {
  layout: layout('a),
  border: border('a),
  backgroundColor: 'a
};

type textLayerStyles('a) = {
  base: viewLayerStyles('a),
  textStyles: textStyles('a)
};

type imageLayerStyles('a) = {base: viewLayerStyles('a)};

type layerStyles('a) =
  | View(viewLayerStyles('a))
  | Text(textLayerStyles('a))
  | Image(imageLayerStyles('a));

/* type styleValues = styles(Types.lonaValue); */
type namedStyles('a) = {
  name: string,
  styles: layerStyles('a)
};

type styleSets('a) = list(namedStyles('a));
/*
 type typeStyleSets = styleSets(Types.lonaType);

 let flexType = {
   alignItems: Types.booleanType,
   alignSelf: Types.booleanType,
   display: Types.booleanType,
   justifyContent: Types.booleanType,
   flex: Types.booleanType,
   flexDirection: Types.booleanType,
   width: Types.booleanType,
   height: Types.booleanType
 };

 let edgeInsetsType = {
   top: Types.booleanType,
   right: Types.booleanType,
   bottom: Types.booleanType,
   left: Types.booleanType
 };

 let viewLayerStylesTypes = {
   layout: {
     flex: flexType,
     padding: edgeInsetsType,
     margin: edgeInsetsType
   },
   border: {
     borderRadius: Types.booleanType,
     borderWidth: Types.booleanType,
     borderColor: Types.booleanType
   }
 }; */
/* let typeStyleSets = [
     {
       name: "normal",
       styles:
         View({
           layout: {
             flex: flexType,
             padding: edgeInsetsType,
             margin: edgeInsetsType
           },
           border: {
             borderRadius: Types.booleanType,
             borderWidth: Types.booleanType,
             borderColor: Types.booleanType
           }
         })
     }
   ]; */