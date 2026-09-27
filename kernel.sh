defconfig_path=arch/arm64/configs/gki_defconfig # No need to edit
defconfig=gki_defconfig # No need to edit
fast_path=$GITHUB_WORKSPACE/gki # This where kernelsource saved
helper=${branch_kernel#*-} # No need to edit
compile_type=${helper%%-*} # No need to edit
 #USE OWN SOURCE KERNEL
link_ur_kernel=https://github.com/B055n1AN/TigerkittyKernel6.6Redmi12-fire-heat.git #Must be edited
branch_ur_kernel=main #Must be edited
#ksu option
use_ksu=y

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

#Compile
make ARCH=arm64 LLVM=1 LLVM_IAS=1 O=out gki_defconfig && make ARCH=arm64 LLVM=1 LLVM_IAS=1 O=out -j$(nproc --all)
