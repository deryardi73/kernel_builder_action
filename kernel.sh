defconfig_path=arch/arm64/configs/new_defconfig # No need to edit
defconfig=new_defconfig # No need to edit
fast_path=$GITHUB_WORKSPACE/gki # This where kernelsource saved
helper=${branch_kernel#*-} # No need to edit
compile_type=${helper%%-*} # No need to edit
 #USE OWN SOURCE KERNEL
link_ur_kernel=https://github.com/deryardi73/gki_kernel.git #Must be edited
branch_ur_kernel=6.6-lts #Must be edited
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

#disable post_defconfig
sed -i 's/POST_DEFCONFIG_CMDS="check_defconfig"/POST_DEFCONFIG_CMDS=""/g' build.config.gki
#point the actual Bazel build at our defconfig instead of the stock gki_defconfig
sed -i "s/^DEFCONFIG=.*/DEFCONFIG=$defconfig/" build.config.gki
#verification defconfig actually wired
grep "^DEFCONFIG=" build.config.gki
#fix
sed -i '/#ifdef USE_PKCS11_ENGINE/{N;/static const char \*key_pass;/s/#ifdef USE_PKCS11_ENGINE\n//}' certs/extract-cert.c
sed -i '/#ifdef USE_PKCS11_ENGINE/{N;/key_pass = getenv/s/#ifdef USE_PKCS11_ENGINE\n//}' certs/extract-cert.c
sed -i '/^#endif$/{x;/key_pass/d;x}' certs/extract-cert.c

#Compile
make ARCH=arm64 LLVM=1 LLVM_IAS=1 O=out new_defconfig && make ARCH=arm64 LLVM=1 LLVM_IAS=1 O=out -j$(nproc --all)
