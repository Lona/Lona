mkdir ComponentStudioIcon.iconset

cp ../ComponentStudio/Assets.xcassets/AppIcon.appiconset/*.png ComponentStudioIcon.iconset

iconutil -c icns ComponentStudioIcon.iconset -o ComponentStudioIcon.icns

rm -R ComponentStudioIcon.iconset
