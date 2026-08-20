#CONFIGURATION
kernelsource=https://github.com/deryardi73/android_kernel_xiaomi_fire.git # Must be edited
kernelname=$(basename "$kernelsource" .git) # No need to edit
branch_kernel=inferno2 # Must be edited
defconfig_path=arch/arm64/configs/fire_defconfig # Must be edited
defconfig=fire_defconfig # Must be edited
fast_path=$GITHUB_WORKSPACE # This where kernelsource saved

cd $fast_path
git clone -b $branch_kernel --depth=1 $kernelsource;wait
cd $fast_path/$kernelname

make O=out ARCH=arm64 $defconfig; printf "Y\n2\n\n\n\nY\n" | make -j$(nproc --all) CC=clang O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu-
