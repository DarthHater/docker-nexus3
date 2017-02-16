#!/bin/bash

# Get command line params
while getopts ":n:b:l:s:g:" opt; do
	case $opt in
		n) NEXUS_VERSION="$OPTARG"
		;;
		b) VERSION_MAJOR="$OPTARG"
		;;
		l) VERSION_MINOR="$OPTARG"
		;;
		s) VERSION_BUILD="$OPTARG"
		;;
		g) GLIBC_VERSION="$OPTARG"
		;;
	esac
done

DIRNAME=${NEXUS_VERSION:0:$#-5}

sedStr="
		s!%%NEXUS_VERSION%%!$NEXUS_VERSION!g;
		s!%%VERSION_MAJOR%%!$VERSION_MAJOR!g;
		s!%%VERSION_MINOR%%!$VERSION_MINOR!g;
		s!%%VERSION_BUILD%%!$VERSION_BUILD!g;
		s!%%GLIBC_VERSION%%!$GLIBC_VERSION!g;
	"

echo "Updating Dockerfile Templates"

for variant in alpine centos ubuntu; do
	if [ ! -d "$DIRNAME/$variant" ]; then
		mkdir -p $DIRNAME/$variant
	fi
	sed -e "$sedStr" "Dockerfile-$variant.template" > $DIRNAME/$variant/Dockerfile
done