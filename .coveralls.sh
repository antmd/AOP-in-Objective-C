#!/bin/bash

XCENV=$(xcodebuild -project AOPProxy.xcodeproj -target "AOPProxy (OSX)" -showBuildSettings)
BUILT_PRODUCTS_DIR="/$(echo $XCENV | grep -i "^\s*BUILT_PRODUCTS_DIR\s=\s" | cut -d/ -f2-)"
CURRENT_ARCH=x86_64
OBJECT_FILE_DIR_normal="/$(echo $XCENV | grep -i "^\s*OBJECT_FILE_DIR_normal\s=\s" | cut -d/ -f2-)"
SRCROOT="/$(echo $XCENV | grep -i "^\s*SRCROOT\s=\s" | cut -d/ -f2-)"
OBJROOT="/$(echo $XCENV | grep -i "^\s*OBJROOT\s=\s" | cut -d/ -f2-)"

declare -r gcov_dir="${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH}/"

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