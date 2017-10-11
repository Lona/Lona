if ! [ -e ComponentStudio.app ]; then
	echo "Put the archived app, ComponentStudio.app, in this directory to update the appcast."
	exit 1
fi

if ! [ -e ComponentStudio.zip ]; then
	echo "You must first build a zip in order to appcast."
	exit 1
fi

if [[ -z "${COMPONENT_STUDIO_DSA_PRIVATE_KEY}" ]]; then
	echo "You must set the path to the private key: COMPONENT_STUDIO_DSA_PRIVATE_KEY"
  	exit 1
fi

if [[ -z "${COMPONENT_STUDIO_APPCAST_DIRECTORY}" ]]; then
	echo "You must set the path to the appcast directory: COMPONENT_STUDIO_APPCAST_DIRECTORY"
  	exit 1
fi

VERSION=$(mdls -name kMDItemVersion ComponentStudio.app | awk -F'"' '{print $2}')
TARGET="$COMPONENT_STUDIO_APPCAST_DIRECTORY"ComponentStudio_"$VERSION".zip

echo "Copying .zip to $TARGET"

cp ComponentStudio.zip "$TARGET"

echo "Generating appcast"

../Pods/Sparkle/bin/generate_appcast "$COMPONENT_STUDIO_DSA_PRIVATE_KEY" "$COMPONENT_STUDIO_APPCAST_DIRECTORY"

echo "Generated appcast!"
echo ""

cat "$COMPONENT_STUDIO_APPCAST_DIRECTORY"appcast.xml

echo ""
echo ""
