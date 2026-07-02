#CONFIGURATION
kernelsource=https://github.com/deryardi73/android_kernel_xiaomi_fire.git # Must be edited
kernelname=$(basename "$kernelsource" .git) # No need to edit
branch_kernel=inferno-proto # Must be edited
defconfig_path=arch/arm64/configs/fire_defconfig # Must be edited
defconfig=fire_defconfig # Must be edited
fast_path=$GITHUB_WORKSPACE # This where kernelsource saved
hooks=manual #only manual hook/kprobes hook, must be edited

cd $fast_path
git clone -b $branch_kernel --depth=1 $kernelsource;wait
cd $fast_path/$kernelname

#KSU DRIVER
curl -LSs "https://raw.githubusercontent.com/backslashxx/KernelSU/refs/heads/master/kernel/setup.sh" | bash -s master

#KSU ACTIVATION
echo "CONFIG_KSU=y" >> $defconfig_path

if [ "$hooks" = "kprobes" ]; then
#KPROBES HOOK
echo "CONFIG_KPROBES=y" >> $defconfig_path
echo "CONFIG_KPROBE_EVENTS=y" >> $defconfig_path
echo "CONFIG_KSU_KPROBES_HOOK=y" >> $defconfig_path
fi

if [ "$hooks" = "manual" ]; then
#MANUAL HOOK
echo "CONFIG_KSU_MANUAL_HOOK=y" >> $defconfig_path
wget https://raw.githubusercontent.com/deryardi73/manual_hook/refs/heads/main/manualhook_1.6_fixed.patch;wait;patch -p1 < manualhook_1.6_fixed.patch
fi

make O=out ARCH=arm64 $defconfig; printf "Y\n2\n\n\n\nY\n" | make -j$(nproc --all) CC=clang O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu-
