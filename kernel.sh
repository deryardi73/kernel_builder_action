#HEAD_CONFIGURATION
kernelsource=https://android.googlesource.com/kernel/manifest # No need to edit
kernelname=Galactic #Must be edited
branch_kernel=common-android15-6.6 # Must be edited
defconfig_path=arch/arm64/configs/gki_defconfig # No need to edit
defconfig=gki_defconfig # No need to edit
fast_path=$GITHUB_WORKSPACE/gki # This where kernelsource saved
helper=${branch_kernel#*-} # No need to edit
compile_type=${helper%%-*} # No need to edit
 #USE OWN SOURCE KERNEL
use_own_kernel=y # y/n 
link_ur_kernel=https://github.com/deryardi73/kernel_common.git #Must be edited
branch_ur_kernel=android15-6.6.30 #Must be edited
#ksu option
use_ksu=n
#END_CONFIGURATION

mkdir -p gki
cd $fast_path
#download kernel source from aosp
repo init -u $kernelsource -b $branch_kernel --depth=1 ;wait;repo sync -c -j$(nproc) --no-clone-bundle --no-tags;wait

if [ "$use_own_kernel" = "y" ]; then
rm -rf common;wait
git clone -b $branch_ur_kernel --depth=1 $link_ur_kernel common ;wait
fi

cd common
if [ "$use_ksu" = "y" ]; then
#KSU DRIVER
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s stable;wait
#KSU ACTIVATION
echo "CONFIG_KSU=y" >> $defconfig_path
#verification ksu
cat $defconfig_path | grep CONFIG_KSU=y
fi

if [ "$use_own_kernel" = "n" ]; then
#Set name for linux kernel
echo "CONFIG_LOCALVERSION=\"-$kernelname-stable\"" >> $defconfig_path
fi

#disable post_defconfig
sed -i 's/POST_DEFCONFIG_CMDS="check_defconfig"/POST_DEFCONFIG_CMDS=""/g' build.config.gki
#disable abi export protection
sed -i 'd' android/abi_gki_protected_exports_aarch64
#Compile
cd ../

cd $fast_path

case "$compile_type" in
    android13|android14|android15|android16)
        ./tools/bazel build --config=fast //common:kernel_aarch64_dist
        ;;
    android12)
        LTO=thin BUILD_CONFIG=common/build.config.gki.aarch64 build/build.sh
        ;;
esac
