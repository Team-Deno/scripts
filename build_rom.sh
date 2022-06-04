#!/usr/bin/env bash

# Copyright (C) 2019 Saalim Quadri <danascape@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

# RobustOS build script

# Setup the directory
mkdir robust
cd robust

# Check if repo command is installed
if [[ -z "$(which repo)" ]]; then
    echo "Install the git-repo package!"
    exit 1
fi

# Set variables.
API_KEY=""
CHAT_ID=""
FORCE_SYNC=""
USE_TELEGRAM=""

# Set Build Flavor
BUILD_ENG=""
BUILD_USER=""
BUILD_USERDEBUG=""

# Setup necessary Telegram functions.
function sendTG() {
	curl -s "https://api.telegram.org/bot$API_KEY/sendmessage" --data "text=${*}&chat_id=$CHAT_ID&parse_mode=HTML" >/dev/null
}

# Sync the android source (depth sync since its a CI)
if [[ -f "build/envsetup.sh" ]]; then
    if [ $USE_TELEGRAM = "1" ]; then
        sendTG "Source already synced."
        sendTG "Skipping Sync."
    else
        echo "Source already synced."
        echo "Skipping Sync."
    fi
else
    if [ $USE_TELEGRAM = "1" ]; then
        sendTG "Syncing Source Code."
    else
        echo "Syncing Source Code."
    fi
    repo init -u https://github.com/ProjectRobust/platform_manifest -b raijin --depth 1
    if [ $FORCE_SYNC = "1" ]; then
        repo sync --force-sync
    else
        repo sync
    fi
fi

# Close QCOM SEPolicy
if [ $USE_TELEGRAM = "1" ]; then
    sendTG "Skipping Sync."
    sendTG "Cloning QCOM SEPolicy repos"
else
    echo "Skipping Sync."
    echo "Cloning QCOM SEPolicy repos"
fi
git clone -b raijin https://github.com/ProjectRobust/device_qcom_sepolicy device/qcom/sepolicy
git clone -b raijin https://github.com/ProjectRobust/device_qcom_sepolicy_vndr device/qcom/sepolicy_vndr

# Clone device configuration repositories
if [ $USE_TELEGRAM = "1" ]; then
    sendTG "Cloning device repositories"
else
    echo "Cloning device repositories"
fi
git clone -b raijin https://github.com/ProjectRobust/device_xiaomi_ginkgo device/xiaomi/ginkgo
git clone -b raijin https://github.com/ProjectRobust/device_xiaomi_ginkgo-sepolicy device/xiaomi/ginkgo-sepolicy
git clone -b raijin --depth 1 https://github.com/ProjectRobust/device_xiaomi_ginkgo-kernel device/xiaomi/ginkgo-kernel
git clone -b raijin --depth 1 https://github.com/ProjectRobust/kernel_xiaomi_ginkgo kernel/xiaomi/ginkgo
git clone -b raijin --depth 1 https://github.com/ProjectRobust/vendor_xiaomi_ginkgo vendor/xiaomi/ginkgo

# Start the build
if [ $USE_TELEGRAM = "1" ]; then
    sendTG "Starting Build"
else
    echo "Starting Build"
fi
source build/envsetup.sh
if [ $BUILD_ENG = "1" ]; then
    lunch robust_ginkgo-eng
elif [ $BUILD_USER = "1" ]; then
    lunch robust_ginkgo-user
elif [ $BUILD_USERDEBUG = "1" ]; then
    lunch robust_ginkgo-userdebug
else
    if [ $USE_TELEGRAM = "1" ]; then
        sendTG "No Build Flavor selected."
	exit 1
    else
        echo "No Build Flavor selected."
	exit 1
    fi
fi
m otapackage -j12

# Check if Build is completed or not
if [[ -f "out/target/product/ginkgo/robust_ginkgo-ota-eng.${KBUILD_USER_HOST}.zip" ]]; then
    if [ $USE_TELEGRAM = "1" ]; then
        sendTG "Build Complete"
    else
        echo "Build Complete"
    fi
else
    if [ $USE_TELEGRAM = "1" ]; then
        sendTG "Build Failed."
        sendTG "Check Logs for details."
	exit 1
    else
        echo "Build Failed."
        echo "Check Logs for details."
	exit 1
    fi
fi
