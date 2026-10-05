defconfig_path=arch/arm64/configs/new_defconfig # No need to edit
defconfig=new_defconfig # No need to edit
fast_path=$GITHUB_WORKSPACE/gki # This where kernelsource saved
helper=${branch_kernel#*-} # No need to edit
compile_type=${helper%%-*} # No need to edit
 #USE OWN SOURCE KERNEL
link_ur_kernel=https://github.com/deryardi73/gki_kernel.git #Must be edited
branch_ur_kernel=base #Must be edited

#Compile
make ARCH=arm64 LLVM=1 LLVM_IAS=1 O=out new_defconfig && make ARCH=arm64 LLVM=1 LLVM_IAS=1 O=out -j$(nproc --all)
