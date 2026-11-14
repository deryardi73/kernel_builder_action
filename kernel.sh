#CONFIGURATION
kernelsource=https://github.com/MiCode/Xiaomi_Kernel_OpenSource.git # Must be edited
kernelname=$(basename "$kernelsource" .git) # No need to edit
branch_kernel=fire-t-oss # Must be edited
defconfig_path=arch/arm64/configs/fire_defconfig # Must be edited
defconfig=fire_defconfig # Must be edited
fast_path=$GITHUB_WORKSPACE # This where kernelsource saved

cd $fast_path
git clone -b $branch_kernel --depth=1 $kernelsource;wait
cd $fast_path/$kernelname

#KSU DRIVER
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash
wget https://raw.githubusercontent.com/deryardi73/manual_hook/refs/heads/main/resukisu.patch;wait;patch -p1 < resukisu.patch

#NOMOUNT
curl https://raw.githubusercontent.com/maxsteeel/nomount/refs/heads/dev/kernel/setup.sh | bash -
echo "CONFIG_NOMOUNT=y" >> $defconfig_path
grep "CONFIG_NOMOUNT" $defconfig_path

#KSU ACTIVATION
echo "CONFIG_KSU=y" >> $defconfig_path
echo "CONFIG_KSU_MANUAL_HOOK=y" >> $defconfig_path

sed -i 's/(u32)thread->base/(u32)(uintptr_t)thread->base/g' drivers/misc/mediatek/cmdq/bridge/cmdq-bdg-mailbox.c

sed -i 's/(u32)data_64ptr/(u32)(uintptr_t)data_64ptr/; s/(u32)data_8ptr/(u32)(uintptr_t)data_8ptr/' drivers/misc/mediatek/eccci/hif/ccci_hif_dpmaif.c

make O=out ARCH=arm64 $defconfig; printf "Y\n2\n\n\n\nY\n" | make -j$(nproc --all) CC=clang O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu-
