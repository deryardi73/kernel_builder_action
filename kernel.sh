#!/bin/sh
set -eu

#HEAD_CONFIGURATION
kernelsource=https://android.googlesource.com/kernel/manifest # No need to edit
kernelname=Galactic #Must be edited
branch_kernel=common-android15-6.6 # Must be edited
defconfig_path=arch/arm64/configs/new_defconfig # No need to edit
defconfig=new_defconfig # No need to edit
fast_path=$GITHUB_WORKSPACE/gki # This where kernelsource saved
helper=${branch_kernel#*-} # No need to edit
compile_type=${helper%%-*} # No need to edit
 #USE OWN SOURCE KERNEL
use_own_kernel=y # y/n
link_ur_kernel=https://github.com/deryardi73/gki_kernel.git #Must be edited
branch_ur_kernel=6.6.30 #Must be edited
#ksu option
use_ksu=y
#encore_fas option
use_encore_fas=y                              # y/n
encore_fas_setup_url="https://raw.githubusercontent.com/rem01project/encore_fas/main/kernel/scripts/setup.sh"
encore_fas_pin="896fa70"                       # pinned commit: HEAD (1f35c2f) currently breaks the build, see notes below

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
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash;wait
#KSU ACTIVATION
echo "CONFIG_KSU=y" >> $defconfig_path
#verification ksu
cat $defconfig_path | grep CONFIG_KSU=y
fi

if [ "$use_encore_fas" = "y" ]; then
#ENCORE_FAS: fetch + integrate the FAS driver into drivers/
curl -LSs "$encore_fas_setup_url" -o /tmp/encore_fas_setup.sh
chmod +x /tmp/encore_fas_setup.sh

sh /tmp/encore_fas_setup.sh "$encore_fas_pin"

sed -i 's/depends on ARM64 && UPROBES && ANDROID/depends on ARM64 \&\& UPROBES/' encore_fas/kernel/Kconfig

#ENCORE_FAS ACTIVATION
grep -q "^CONFIG_UPROBES=y" $defconfig_path || echo "CONFIG_UPROBES=y" >> $defconfig_path
echo "CONFIG_ENCORE_FAS=y" >> $defconfig_path
#verification encore_fas
cat $defconfig_path | grep -E "CONFIG_ENCORE_FAS=y|CONFIG_UPROBES=y"
fi

if [ "$use_own_kernel" = "n" ]; then
#Set name for linux kernel
echo "CONFIG_LOCALVERSION=\"-$kernelname-stable\"" >> $defconfig_path
fi

#disable post_defconfig
sed -i 's/POST_DEFCONFIG_CMDS="check_defconfig"/POST_DEFCONFIG_CMDS=""/g' build.config.gki
#point the actual Bazel build at our defconfig instead of the stock gki_defconfig
sed -i "s/^DEFCONFIG=.*/DEFCONFIG=$defconfig/" build.config.gki
#verification defconfig actually wired
grep "^DEFCONFIG=" build.config.gki

git add -A
git commit -m "ci: bake in KSU + encore_fas + defconfig + build.config tweaks"

#Compile
cd ../

cd $fast_path

case "$compile_type" in
    android13|android14|android15|android16)
        ./tools/bazel build --config=fast --config=stamp --nokmi_symbol_list_strict_mode //common:kernel_aarch64_dist
        ;;
    android12)
        LTO=thin BUILD_CONFIG=common/build.config.gki.aarch64 build/build.sh
        ;;
esac
