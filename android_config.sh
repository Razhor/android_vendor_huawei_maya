#!/bin/bash
#######################################################################
##
## description : generate config.h of libffmpeg.so
## 
#######################################################################

PREBUILT=../../../prebuilts/gcc/linux-x86/arm/arm-eabi-4.8
PLATFORM=../../../out/target/product/hi6210sft
FF_CONFIG_OPTIONS="
    --target-os=linux
    --arch=arm 
    --enable-demuxers 
    --enable-decoders 
    --enable-decoder=flac    
    --disable-decoder=mjpeg	 
    --disable-stripping 
    --disable-ffmpeg 
    --disable-ffplay 
    --disable-ffserver 
    --disable-ffprobe 
    --disable-encoders 
    --disable-muxers 
    --enable-muxer=spdif
    --disable-devices 
    --enable-parsers
    --disable-bsfs
    --disable-protocols
    --enable-protocol=file 
    --enable-protocol=http
    --enable-protocol=https
    --disable-filters 
    --disable-avdevice 
    --enable-cross-compile 
    --cross-prefix=arm-eabi- 
    --disable-asm 
    --enable-neon 
    --enable-armv5te 
    --disable-postproc
    --disable-logging
"

FF_CONFIG_OPTIONS=`echo $FF_CONFIG_OPTIONS`

./configure ${FF_CONFIG_OPTIONS} \
    --extra-cflags="-fPIC -DANDROID -I../../../bionic/libc/include/ -I../../../bionic/libc/arch-arm/include -I../../../bionic/libc/kernel/common -I../../../bionic/libc/kernel/arch-arm" \
    --extra-ldflags="-Wl,-T,$PREBUILT/arm-eabi/lib/ldscripts/armelf.x \
                     -Wl,-rpath-link=$PLATFORM/system/lib -L$PLATFORM/system/lib -nostdlib \
                     $PREBUILT/lib/gcc/arm-eabi/4.8/crtbegin.o \
                     $PREBUILT/lib/gcc/arm-eabi/4.8/crtend.o -lc -lm -ldl"

tmp_file=".tmpfile"
## remove invalid restrict define
sed 's/#define av_restrict restrict/#define av_restrict/' ./config.h >$tmp_file
mv $tmp_file ./config.h

## replace original FFMPEG_CONFIGURATION define with $FF_CONFIG_OPTIONS
sed '/^#define FFMPEG_CONFIGURATION/d' ./config.h >$tmp_file
mv $tmp_file ./config.h
total_line=`wc -l ./config.h | cut -d' ' -f 1`
tail_line=`expr $total_line - 3`
head -3 config.h > $tmp_file
echo "#define FFMPEG_CONFIGURATION \"${FF_CONFIG_OPTIONS}\"" >> $tmp_file
tail -$tail_line config.h >> $tmp_file
mv $tmp_file ./config.h

rm -f config.err

## rm BUILD_ROOT information
sed '/^BUILD_ROOT=/d' ./config.mak > $tmp_file
rm -f ./config.mak
mv $tmp_file ./config.mak

## rm amr-eabi-gcc
sed '/^CC=arm-eabi-gcc/d' ./config.mak > $tmp_file
rm -f ./config.mak
mv $tmp_file ./config.mak

## rm amr-eabi-gcc
sed '/^AS=arm-eabi-gcc/d' ./config.mak > $tmp_file
rm -f ./config.mak
mv $tmp_file ./config.mak


## rm amr-eabi-gcc
sed '/^LD=arm-eabi-gcc/d' ./config.mak > $tmp_file
rm -f ./config.mak
mv $tmp_file ./config.mak

## rm amr-eabi-gcc
sed '/^DEPCC=arm-eabi-gcc/d' ./config.mak > $tmp_file
rm -f ./config.mak
mv $tmp_file ./config.mak

## other work need to be done manually
cat <<!EOF
#####################################################
                    ****NOTICE**** 
You need to modify the file config.mak and delete 
all full path string in macro:
SRC_PATH, SRC_PATH_BARE, BUILD_ROOT, LDFLAGS.
Please refer to the old version of config.mak to 
check how to modify it.
#####################################################
!EOF
