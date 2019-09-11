#!/bin/bash

DIR=$(dirname "$0")

pushd "$DIR"/../build

if [[ -z "${LONASTUDIO_APPCAST_DIRECTORY}" ]]; then
	echo "You must set the path to the appcast directory: LONASTUDIO_APPCAST_DIRECTORY"
	exit 1
fi

if ! [ -e LonaStudio.app ]; then
	echo "Put the archived app, LonaStudio.app, in this directory to update the appcast."
	exit 1
fi

../dmg/build-dmg.sh

VERSION=$(plutil -p LonaStudio.app/Contents/Info.plist | grep CFBundleShortVersionString | grep -o '[0-9.]\+')
TARGET="$LONASTUDIO_APPCAST_DIRECTORY"/LonaStudio_"$VERSION".dmg

echo "Copying .dmg to $TARGET"

cp LonaStudio.dmg "$TARGET"

echo "Generating appcast"

../Pods/Sparkle/bin/generate_appcast "$LONASTUDIO_APPCAST_DIRECTORY"

echo "Generated appcast!"
echo ""

cat "$LONASTUDIO_APPCAST_DIRECTORY"/appcast.xml

echo ""
echo ""

popd