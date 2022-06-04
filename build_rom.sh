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

# Sync the android source (depth sync since its a CI)
repo init -u https://github.com/ProjectRobust/platform_manifest -b raijin --depth 1
repo sync

# Close QCOM SEPolicy
git clone -b raijin https://github.com/ProjectRobust/device_qcom_sepolicy device/qcom/sepolicy
git clone -b raijin https://github.com/ProjectRobust/device_qcom_sepolicy_vndr device/qcom/sepolicy_vndr

# Clone device configuration repositories
git clone -b raijin https://github.com/ProjectRobust/device_xiaomi_ginkgo device/xiaomi/ginkgo
git clone -b raijin https://github.com/ProjectRobust/device_xiaomi_ginkgo-sepolicy device/xiaomi/ginkgo-sepolicy
git clone -b raijin --depth 1 https://github.com/ProjectRobust/device_xiaomi_ginkgo-kernel device/xiaomi/ginkgo-kernel
git clone -b raijin --depth 1 https://github.com/ProjectRobust/kernel_xiaomi_ginkgo kernel/xiaomi/ginkgo
git clone -b raijin --depth 1 https://github.com/ProjectRobust/vendor_xiaomi_ginkgo vendor/xiaomi/ginkgo

# Start the build
source build/envsetup.sh
lunch robust_ginkgo-userdebug
m otapackage -j12
