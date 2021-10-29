#!/bin/bash
# 打包

BUILD_DIR=$(cd "$(dirname "$0")"; pwd)
ROOT_DIR=$(dirname "$BUILD_DIR")

APP_NAME="smplayer"
APP_VER=$(sed -n '/MARKETING_VERSION/{s/MARKETING_VERSION = //;s/;//;s/^[[:space:]]*//;p;q;}' $ROOT_DIR/smplayer/smplayer.xcodeproj/project.pbxproj)
APP_RELEASE=${BUILD_DIR}/release

DMG_FINAL="${APP_NAME}.dmg"


function build(){
	mkdir -p $APP_RELEASE

	echo "build smplayer."${APP_VER}

	# echo "Building archive... please wait a minute"
    xcodebuild -workspace $ROOT_DIR/${APP_NAME}/${APP_NAME}.xcworkspace -config Release -scheme ${APP_NAME} -archivePath ${BUILD_DIR}/release.xcarchive archive

    echo "Exporting archive...√"
    xcodebuild -archivePath ${BUILD_DIR}/release.xcarchive -exportArchive -exportPath ${APP_RELEASE} -exportOptionsPlist $BUILD_DIR/build.plist

}


function createDmgByAppdmg(){

	# umount "/Volumes/${APP_NAME}"

	rm -rf ${BUILD_DIR}/${APP_NAME}.app ${BUILD_DIR}/${DMG_FINAL}
	\cp -Rf "${APP_RELEASE}/${APP_NAME}.app" "${BUILD_DIR}/${APP_NAME}.app"

	# npm install -g appdmg
	echo ${BUILD_DIR}/appdmg.json
    appdmg appdmg.json ${DMG_FINAL}

    # umount "/Volumes/${APP_NAME}"
}

function makeDmg(){

	# rm -fr ${DMG_FINAL} ${APP_RELEASE}
	
	build
	createDmgByAppdmg
}


echo $ROOT_DIR
if [ "$1" = "build" ]
then
	build

else
    makeDmg
fi
echo 'done'
