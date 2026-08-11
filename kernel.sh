#CONFIGURATION
kernelsource=https://github.com/deryardi73/android_kernel_xiaomi_fire.git # Must be edited
kernelname=$(basename "$kernelsource" .git) # No need to edit
branch_kernel=inferno_mglru # Must be edited
defconfig_path=arch/arm64/configs/fire_defconfig # Must be edited
defconfig=fire_defconfig # Must be edited
fast_path=$GITHUB_WORKSPACE # This where kernelsource saved
hooks=manual #only manual hook/kprobes hook, must be edited
susfs=y

cd $fast_path
git clone -b $branch_kernel --depth=1 $kernelsource;wait
cd $fast_path/$kernelname

if [ "$susfs" = "y" ]; then
curl -LSs https://raw.githubusercontent.com/Youffx/KernelSU-Next/legacy-susfs/kernel/setup.sh | bash -s legacy-susfs
echo "CONFIG_KSU_SUSFS=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SUS_MOUNT=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SUS_KSTAT=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SPOOF_UNAME=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y" >> $defconfig_path
echo "CONFIG_KSU_SUSFS_SUS_MAP=y" >> $defconfig_path
fi

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

if ! grep -q susfs_kstat_hook fs/stat.c; then
sed -i '/^void generic_fillattr(struct inode \*inode, struct kstat \*stat)/,/^}/{
/stat->attributes |= STATX_ATTR_AUTOMOUNT;/a\
#ifdef CONFIG_KSU\
\textern void (*susfs_kstat_hook)(struct inode *inode, struct kstat *stat);\
\tif (unlikely(susfs_kstat_hook))\
\t\tsusfs_kstat_hook(inode, stat);\
#endif
}' fs/stat.c
fi

if ! grep -q susfs_uname_hook kernel/sys.c; then
sed -i '/^SYSCALL_DEFINE1(newuname, struct new_utsname __user \*, name)/,/^}/{
/^\tup_read(&uts_sem);/a\
#ifdef CONFIG_KSU\
\textern void (*susfs_uname_hook)(struct new_utsname *tmp);\
\tif (unlikely(susfs_uname_hook))\
\t\tsusfs_uname_hook(&tmp);\
#endif
}' kernel/sys.c
fi

make O=out ARCH=arm64 $defconfig; printf "Y\n2\n\n\n\nY\n" | make -j$(nproc --all) CC=clang O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu-
