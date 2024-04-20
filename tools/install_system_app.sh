#!/bin/bash

# CHANGE THESE FOR YOUR APP
app_package="com.opensync.app"
dir_app_name="OpenSync"
MAIN_ACTIVITY="MainActivity"

ADB="adb" # how you execute adb
ADB_SH="$ADB shell" # this script assumes using `adb root`. for `adb su` see `Caveats`

path_sysapp="/system/app/"
apk_host="src/app/build/outputs/apk/release/OpenSync-release-*.apk"
apk_name=OpenSync.apk
apk_target_dir="$path_sysapp/$dir_app_name"
apk_target_sys="$apk_target_dir/$apk_name"

# Delete previous APK
# rm -f $apk_host

# Compile the APK: you can adapt this for production build, flavors, etc.
# ./gradlew assembleRelease || exit -1 # exit on failure

# Install APK: using adb root
$ADB root 2> /dev/null
$ADB remount # mount system

[ z$1 == zu ] && {
    $ADB_SH rm -rf $apk_target_dir
} || {
    $ADB push $apk_host $apk_target_sys

    # Give permissions
    $ADB_SH "chmod 755 $apk_target_dir"
    $ADB_SH "chmod 644 $apk_target_sys"
}

$ADB reboot
