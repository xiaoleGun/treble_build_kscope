#!/bin/bash
echo ""
echo "KaleidosopeOS Treble Buildbot"
echo "Executing in 3 seconds - CTRL-C to exit"
echo ""

sleep 3
set -e

START=`date +%s`
BUILD_DATE="$(date +%Y%m%d)"
WITHOUT_CHECK_API=true
BL=$PWD/treble_build_kscope
BD=$HOME/builds
VERSION=beta1

syncrepo() {
if [ ! -d .repo ]
then
    echo "Initializing KaleidosopeOS workspace"
    repo init -u https://github.com/Project-Kaleidosope/android_manifest sunflowerleaf --depth=1
    echo ""
fi

if [ -d .repo ]
then
    if [ ! -d .repo/local_manifests ]
    then
     echo "Preparing local manifest"
     mkdir -p .repo/local_manifests
     cp ./treble_build_kscope/local_manifests_treble/manifest.xml .repo/local_manifests/kscope-treble.xml
     echo ""
    fi 
fi

echo "Syncing repos"
repo sync
echo ""
}

applypatches() {
patches="$(readlink -f -- $1)"
tree="$2"

for project in $(cd $patches/patches/$tree; echo *);do
	p="$(tr _ / <<<$project |sed -e 's;platform/;;g')"
	[ "$p" == treble/app ] && p=treble_app
	[ "$p" == vendor/hardware/overlay ] && p=vendor/hardware_overlay
	pushd $p
	for patch in $patches/patches/$tree/$project/*.patch;do
		git am $patch || exit
	done
	popd
    done
}

applyingpatches() {
echo "Applying patches"
applypatches $BL personal
applypatches $BL phh
echo ""
}

initenvironment() {
echo "Setting up build environment"
source build/envsetup.sh &> /dev/null
mkdir -p $BD
echo ""
}

buildTrebleApp() {
    cd treble_app
    bash build.sh release
    cp TrebleApp.apk ../vendor/hardware_overlay/TrebleApp/app.apk
    cd ..
}

buildtreble() {
    lunch kscope_treble-userdebug
    make installclean
    make -j$(nproc --all) systemimage
    mv $OUT/system.img $BD/system-kscope_treble.img
}

generatePackages() {
    rm -rf $BD/Kaleidoscope-*.img.xz
    BASE_IMAGE=$BD/system-kscope_treble.img
    xz -cv $BASE_IMAGE -T0 > $BD/Kaleidoscope-sunflowerleaf-arm64-ab-$BUILD_DATE-UNOFFICIAL.img.xz
}

generateOtaJson() {
    prefix="Kaleidoscope-sunflowerleaf-"
    suffix="-$BUILD_DATE-UNOFFICIAL.img.xz"
    json="{\"version\": \"$VERSION\",\"date\": \"$(date +%s -d '-4hours')\",\"variants\": ["
    find $BD -name "*.img.xz" | {
        while read file; do
            packageVariant=$(echo $(basename $file) | sed -e s/^$prefix// -e s/$suffix$//)
            case $packageVariant in
                "arm64-ab") name="kscope_treble";;
            esac
            size=$(wc -c $file | awk '{print $1}')
            url="https://github.com/xiaoleGun/treble_build_kscope/releases/download/$VERSION/$(basename $file)"
            json="${json} {\"name\": \"$name\",\"size\": \"$size\",\"url\": \"$url\"},"
        done
        json="${json%?}]}"
        echo "$json" | jq . > $BL/ota.json
        cp -r $BL/ota.json $BD/ota.json
    }
}

personal() {
  7z a -t7z -r $BD/all.7z $BD/*
  rm -rf $BD/*.img.xz
  rm -rf $BD/ota.json
}

syncrepo
applyingpatches
initenvironment
buildTrebleApp
buildtreble
generatePackages
generateOtaJson
if [ $USER == xiaolegun ];then
personal
fi

END=`date +%s`
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))
echo "Buildbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo ""
