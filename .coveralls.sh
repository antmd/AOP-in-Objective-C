#!/bin/zsh

cd $(dirname $0)
ZZCONFIGURATION="Debug"
ZZXCENV=`xcodebuild -project AOPProxy.xcodeproj -target "AOPProxy (OSX)" -showBuildSettings`
ZZBUILT_PRODUCTS_DIR="/`echo ${ZZXCENV} | grep -i '^\s*BUILT_PRODUCTS_DIR\s=\s' | cut -d/ -f2-`"
ZZCURRENT_ARCH='x86_64'
ZZPROJECT_TEMP_DIR="/`echo ${ZZXCENV} | grep -i '^\s*PROJECT_TEMP_DIR\s=\s' | cut -d/ -f2-`"
# ZZSRCROOT="/$(echo $XCENV | grep -i "^\s*SRCROOT\s=\s" | cut -d/ -f2-)"
# ZZOBJROOT="/$(echo $XCENV | grep -i "^\s*OBJROOT\s=\s" | cut -d/ -f2-)"

echo -e "BUILT_PRODUCTS_DIR is $ZZBUILT_PRODUCTS_DIR"
echo -e "CURRENT_ARCH is $ZZCURRENT_ARCH"
# echo -e "OBJECT_FILE_DIR_normal is $OBJECT_FILE_DIR_normal"
# echo -e "SRCROOT is $SRCROOT"
# echo -e "OBJROOT is $OBJROOT"


# declare -r
gcov_dir="${ZZPROJECT_TEMP_DIR}/${ZZCONFIGURATION}/AOPProxy (OSX).build/Objects-normal/${ZZCURRENT_ARCH}"
echo -e "gcov_dir is $gcov_dir"

# {OBJECT_FILE_DIR_normal}/${CURRENT_ARCH}/"

## ======

generateGcov()
{
	#  doesn't set output dir to gcov...
	cd "${gcov_dir}"
	for file in ${gcov_dir}/*.gcda
	do
		gcov-4.2 "${file}" -o "${gcov_dir}"
	done
	cd -
}

copyGcovToProjectDir()
{
	cp -r "${gcov_dir}" gcov
}

removeGcov()
{
	rm -r gcov
}

main()
{
# generate + copy
	generateGcov
	copyGcovToProjectDir
# post
	coveralls ${@+"$@"}
# clean up
	removeGcov
}

main ${@+"$@"}