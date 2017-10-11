[ -e ComponentStudio.dmg ] && rm ComponentStudio.dmg

if ! [ -e ComponentStudio.app ]; then
	echo "Put the archived app, ComponentStudio.app, in this directory to build a dmg."
	exit 1
fi

# npm install -g appdmg
appdmg appdmg.json ComponentStudio.dmg

# https://stackoverflow.com/questions/23824815/how-to-add-codesigning-to-dmg-file-in-mac
codesign -s "Developer ID Application: Devin Abbott (CV2RHZWPY9)" ComponentStudio.dmg
