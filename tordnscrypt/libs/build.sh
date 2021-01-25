#!/bin/bash

############
## Config ##
############

if [[ $# == 1 && $1 == "arm64" ]]
then
    ARM64=true
    echo "#compile arm64-v8a things..."
else
    ARM64=false
    echo "#compile armeabi-v7a things..."
fi

obfs4proxy_version=obfs4proxy-0.0.11
dnscryptproxy_version=2.0.44
snowflake_version=7043a055f9fb0680281ecffd7d458a43f2ce65b5
tor_openssl_version=OpenSSL_1_1_1h
i2pd_openssl_version=OpenSSL_1_1_1g
libevent_version=release-2.1.11-stable
zstd_version=v1.4.5
xz_version=v5.2.3
tor_version=release-0.4.4

NDK="/opt/android-sdk/ndk/21.3.6528147"
export ANDROID_NDK_HOME=$NDK
export PATH="$PATH:$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"
LIBS_ROOT=`pwd`

if [ $ARM64 ]
then
    export CC="aarch64-linux-android29-clang"
    export CCX="aarch64-linux-android29-clang++"
    export GOARCH=arm64
    ABI=arm64-v8a
else
    export CC="armv7a-linux-androideabi16-clang"
    export CCX="armv7a-linux-androideabi16-clang++"
    export GOARCH=arm
    ABI=armeabi-v7a
fi

export CGO_ENABLED=1
export GOOS="android"

##############
##############

# Clean
rm -r -f arm64-v8a armeabi-v7a
mkdir arm64-v8a armeabi-v7a

#################
# libobfs4proxy #
#################

git clone --single-branch --branch $obfs4proxy_version https://github.com/Yawning/obfs4
cd obfs4/obfs4proxy/

go build -ldflags="-s -w" -o libobfs4proxy.so
mv libobfs4proxy.so ${LIBS_ROOT}/${ABI}/libobfs4proxy.so

cd $LIBS_ROOT

#####################
# libdnscrypt-proxy #
#####################

git clone --single-branch --branch $dnscryptproxy_version https://github.com/DNSCrypt/dnscrypt-proxy
cd dnscrypt-proxy/dnscrypt-proxy/

go build -ldflags="-s -w" -o libdnscrypt-proxy.so
mv libdnscrypt-proxy.so ${LIBS_ROOT}/${ABI}/libdnscrypt-proxy.so

cd $LIBS_ROOT

################
# libsnowflake #
################

git clone https://github.com/keroserene/snowflake
cd snowflake/
git checkout -f $snowflake_version -b $snowflake_version
cd proxy/

go build -ldflags="-s -w" -o libsnowflake.so
mv libsnowflake.so ${LIBS_ROOT}/${ABI}/libsnowflake.so

cd $LIBS_ROOT

##########
# libtor #
##########

cd ../../TorBuildScript/external/
export EXTERNAL_ROOT=`pwd`

git clone --single-branch --branch $tor_openssl_version https://github.com/openssl/openssl.git
git clone --single-branch --branch $libevent_version https://github.com/libevent/libevent.git
git clone --single-branch --branch $zstd_version https://github.com/facebook/zstd.git
git clone --single-branch --branch $xz_version https://git.tukaani.org/xz.git
git clone --single-branch --branch $tor_version https://git.torproject.org/tor.git

if [ $ARM64 ]
then
    #compile arm64-v8a things...
    #android r20 22 default arm64-v8a
    APP_ABI=arm64 NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make clean
    APP_ABI=arm64 NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make
    APP_ABI=arm64 NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make showsetup
else
    #compile armeabi-v7a things...
    #android r20 22 default armeabi-v7a
    APP_ABI=armeabi make clean
    APP_ABI=armeabi make
    APP_ABI=armeabi make showsetup
fi

mv ../tor-android-binary/src/main/libs/${ABI}/libtor.so ${LIBS_ROOT}/${ABI}/libtor.so

cd $LIBS_ROOT

###########
# libi2pd #
###########

cd ../../PurpleI2PBuildScript/external/
mkdir -p libs
export EXTERNAL_ROOT=`pwd`

cd libs/
git clone --single-branch --branch $i2pd_openssl_version https://github.com/openssl/openssl.git
git clone https://github.com/moritz-wundke/Boost-for-Android.git
git clone https://github.com/miniupnp/miniupnp.git
git clone https://github.com/PurpleI2P/android-ifaddrs.git
cd ../

git clone https://github.com/PurpleI2P/i2pd.git

if [ $ARM64 ]
then
    #compile arm64-v8a things...
    #android r20b 21 default arm64-v8a:
    export TARGET_I2P_ABI=arm64-v8a
    export TARGET_I2P_PLATFORM=21
    APP_ABI=arm64-v8a NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make clean
    APP_ABI=arm64-v8a NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make
    APP_ABI=arm64-v8a NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make showsetup
else
    #compile armeabi-v7a things...
    #android r20b 16 default armeabi-v7a:
    export TARGET_I2P_ABI=armeabi-v7a
    export TARGET_I2P_PLATFORM=16
    APP_ABI=armeabi-v7a make clean
    APP_ABI=armeabi-v7a make
    APP_ABI=armeabi-v7a make showsetup
fi

mv ../i2pd-android-binary/src/main/libs/${ABI}/libi2pd.so ${LIBS_ROOT}/${ABI}/libi2pd.so

cd $LIBS_ROOT
