
cd /xcodes/openSource/smooth-drawing/Smooth\ Drawing/Build
mkdir -p ipa/Payload
cp -r /Users/apple/Library/Developer/Xcode/DerivedData/Smooth_Drawing-gnxapairjjqocxfwcwrclohyqkis/Build/Products/Debug-iphoneos/Smooth\ Drawing.app ipa/Payload
cd ipa
zip -r Smooth\ Drawing.ipa *
cd ..
#./Tools/ipa_ota ./ipa/MicroPPT.ipa http://www.88yun.org/tony/ > download_app.html
#scp ./download_app.html tony@66.175.220.101:~/www/download_app.html
#scp ./MicroPPT.plist tony@66.175.220.101:~/www/MicroPPT.plist
#scp ./MicroPPT.plist debug@lightmail.cn:~/www/apps/MicroPPT/iOS/iPhone/qiduo.plist
scp ./ipa/Smooth\ Drawing.ipa debug@lightmail.cn:~/www/apps/SmoothDrawing/iOS/iPhone/qiduo.ipa