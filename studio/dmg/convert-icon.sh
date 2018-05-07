mkdir LonaStudioIcon.iconset

cp ../LonaStudio/Assets.xcassets/AppIcon.appiconset/*.png LonaStudioIcon.iconset

iconutil -c icns LonaStudioIcon.iconset -o LonaStudioIcon.icns

rm -R LonaStudioIcon.iconset
