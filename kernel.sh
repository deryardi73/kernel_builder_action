#CONFIGURATION
kernelsource=https://github.com/deryardi73/android_kernel_xiaomi_fire.git # Must be edited
kernelname=$(basename "$kernelsource" .git) # No need to edit
branch_kernel=inferno-new # Must be edited
defconfig_path=arch/arm64/configs/fire_defconfig # Must be edited
defconfig=fire_defconfig # Must be edited
fast_path=$GITHUB_WORKSPACE # This where kernelsource saved

cd $fast_path
git clone -b $branch_kernel --depth=1 $kernelsource;wait
cd $fast_path/$kernelname

#KSU DRIVER
wget https://raw.githubusercontent.com/deryardi73/manual_hook/refs/heads/main/susfs.patch;wait;patch -p1 < susfs.patch
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash
wget https://raw.githubusercontent.com/JackA1ltman/NonGKI_Kernel_Build_2nd/refs/heads/mainline/Patches/susfs_inline_hook_patches.sh
chmod +x susfs_inline_hook_patches.sh && ./susfs_inline_hook_patches.sh

#NOMOUNT
curl https://raw.githubusercontent.com/maxsteeel/nomount/refs/heads/dev/kernel/setup.sh | bash -
echo "CONFIG_NOMOUNT=y" >> $defconfig_path
grep "CONFIG_NOMOUNT" $defconfig_path

#KSU ACTIVATION
echo "CONFIG_KSU=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SUS_PATH=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SUS_MOUNT=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SUS_KSTAT=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_TRY_UMOUNT=n" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SPOOF_UNAME=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_ENABLE_LOG=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SUS_MAP=y" >> $defconfig_path
echo "CONFIG_KALLSYMS_ALL=y" >> $defconfig_path

make O=out ARCH=arm64 $defconfig; printf "Y\n2\n\n\n\nY\n" | make -j$(nproc --all) CC=clang O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu-
