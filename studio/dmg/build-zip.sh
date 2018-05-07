[ -e LonaStudio.zip ] && rm LonaStudio.zip

if ! [ -e LonaStudio.app ]; then
	echo "Put the archived app, LonaStudio.app, in this directory to build a zip."
	exit 1
fi

# zip it while preserving metadata
# https://github.com/sparkle-project/Sparkle/issues/433
# https://github.com/electron/electron/issues/905
ditto -c -k --sequesterRsrc --keepParent LonaStudio.app LonaStudio.zip
