[ -e LonaStudio.dmg ] && rm LonaStudio.dmg

if ! [ -e LonaStudio.app ]; then
	echo "Put the archived app, LonaStudio.app, in this directory to build a dmg."
	exit 1
fi

# npm install -g appdmg
appdmg appdmg.json LonaStudio.dmg

# https://stackoverflow.com/questions/23824815/how-to-add-codesigning-to-dmg-file-in-mac
codesign -s "Developer ID Application: Devin Abbott (CV2RHZWPY9)" LonaStudio.dmg
