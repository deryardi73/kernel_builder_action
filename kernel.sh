#CONFIGURATION
kernelsource=https://github.com/mt6768-dev/android_kernel_xiaomi_mt6768.git # Must be edited
kernelname=$(basename "$kernelsource" .git) # No need to edit
branch_kernel=lineage-23.2 # Must be edited
defconfig_path=arch/arm64/configs/vendor/lancelot_defconfig # Must be edited
defconfig=vendor/lancelot_defconfig # Must be edited
fast_path=$GITHUB_WORKSPACE # This where kernelsource saved

cd $fast_path
git clone -b $branch_kernel --depth=1 $kernelsource;wait
cd $fast_path/$kernelname

#KSU DRIVER
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash
wget https://raw.githubusercontent.com/deryardi73/manual_hook/refs/heads/main/manualhook.patch;wait;patch -p1 < manualhook.patch

#KSU ACTIVATION
echo "CONFIG_KSU=y" >> $defconfig_path
echo "CONFIG_KSU_MANUAL_HOOK=y" >> $defconfig_path

make O=out ARCH=arm64 $defconfig; printf "Y\n2\n\n\n\nY\n" | make -j$(nproc --all) CC=clang O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu-
