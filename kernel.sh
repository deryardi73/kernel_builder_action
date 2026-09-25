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
branch_ur_kernel=6.6-lts #Must be edited
#ksu option
use_ksu=y

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

#Compile
make O=out ARCH=arm64 mrproper && make O=out ARCH=arm64 new_defconfig && make -j$(nproc --all) CC=clang O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu-
