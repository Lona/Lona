[ -e ComponentStudio.zip ] && rm ComponentStudio.zip

if ! [ -e ComponentStudio.app ]; then
	echo "Put the archived app, ComponentStudio.app, in this directory to build a zip."
	exit 1
fi

# zip it while preserving metadata
# https://github.com/sparkle-project/Sparkle/issues/433
# https://github.com/electron/electron/issues/905
ditto -c -k --sequesterRsrc --keepParent ComponentStudio.app ComponentStudio.zip
