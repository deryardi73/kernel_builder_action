defconfig_path=arch/arm64/configs/gki_defconfig # No need to edit
defconfig=gki_defconfig # No need to edit
fast_path=$GITHUB_WORKSPACE/gki # This where kernelsource saved
helper=${branch_kernel#*-} # No need to edit
compile_type=${helper%%-*} # No need to edit
 #USE OWN SOURCE KERNEL
link_ur_kernel=https://github.com/deryardi73/gki_kernel.git #Must be edited
branch_ur_kernel=6.6-lts #Must be edited
#ksu option
use_ksu=y
susfs=y

git clone -b $branch_ur_kernel --depth=1 $link_ur_kernel common ;wait

cd common
if [ "$use_ksu" = "y" ]; then
#KSU DRIVER
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash;wait
#KSU ACTIVATION
echo "CONFIG_KSU=y" >> $defconfig_path
#verification ksu
cat $defconfig_path | grep CONFIG_KSU=y
fi

if [ "susfs" = "y" ]; then
wget https://raw.githubusercontent.com/deryardi73/manual_hook/refs/heads/main/50_add_susfs_in_gki-android15-6_6-fixed.patch
patch -p1 < 50_add_susfs_in_gki-android15-6_6-fixed.patch
echo "CONFIG_KSU_SUSFS=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SUS_PATH=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SUS_MOUNT=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SUS_KSTAT=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SUS_MAP=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SPOOF_UNAME=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_ENABLE_LOG=y" >> $defconfig_path

#Compile
make ARCH=arm64 LLVM=1 LLVM_IAS=1 O=out new_defconfig && make ARCH=arm64 LLVM=1 LLVM_IAS=1 O=out -j$(nproc --all)
