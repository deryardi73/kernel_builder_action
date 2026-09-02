#CONFIGURATION
kernelsource=https://github.com/mt6768-dev/android_kernel_xiaomi_mt6768.git # Must be edited
kernelname=$(basename "$kernelsource" .git) # No need to edit
branch_kernel=lineage-23.2 # Must be edited
DEVICE=${DEVICE:-lancelot} # Ganti ke "merlin" buat build device itu, atau set env DEVICE saat manggil script (contoh: DEVICE=merlin sh kernel.sh)
base_defconfig=arch/arm64/configs/vendor/mt6768_defconfig # Base defconfig (sama buat semua device di chipset ini)
vendor_fragment=arch/arm64/configs/vendor/${DEVICE}.config # Fragment device, otomatis ikut $DEVICE
fast_path=$GITHUB_WORKSPACE # This where kernelsource saved

cd $fast_path
git clone -b $branch_kernel --depth=1 $kernelsource;wait
cd $fast_path/$kernelname

#KSU DRIVER
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash
wget https://raw.githubusercontent.com/deryardi73/manual_hook/refs/heads/main/manualhook.patch;wait;patch -p1 < manualhook.patch

#KSU FRAGMENT (jangan langsung echo ke defconfig, itu yang bikin defconfig ke-overwrite jadi 2 baris doang)
cat > /tmp/ksu.config << EOF
CONFIG_KSU=y
CONFIG_KSU_MANUAL_HOOK=y
EOF

#MERGE base defconfig + vendor fragment + KSU fragment jadi satu .config yang lengkap
mkdir -p out
ARCH=arm64 scripts/kconfig/merge_config.sh -m -O out \
  $base_defconfig \
  $vendor_fragment \
  /tmp/ksu.config

#Resolve dependency yang baru ke-merge (WAJIB, biar simbol turunannya konsisten)
make O=out ARCH=arm64 olddefconfig

printf "Y\n2\n\n\n\nY\n" | make -j$(nproc --all) CC=clang O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu-
