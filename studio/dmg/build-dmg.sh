DIR=$(dirname "$0")

pushd "$DIR"/../build

[ -e LonaStudio.dmg ] && rm LonaStudio.dmg

if ! [ -e LonaStudio.app ]; then
	echo "Put the archived app, LonaStudio.app, in the ../build directory to build a zip."
	exit 1
fi

# npm install -g appdmg
appdmg ../dmg/appdmg.json LonaStudio.dmg

popd