#!/bin/bash

############
## Config ##
############

ndk_version=21.3.6528147
obfs4proxy_version=obfs4proxy-0.0.11
dnscryptproxy_version=2.0.44
snowflake_version=webext-0.2.2
tor_openssl_version=OpenSSL_1_1_1h
libevent_version=release-2.1.11-stable
zstd_version=v1.4.5
xz_version=v5.2.3
tor_version=release-0.4.4
i2pd_openssl_version=OpenSSL_1_1_1g
i2pd_version=2.35.0

if [[ $# == 1 && $1 == "arm64" ]]
then
    ABI=arm64-v8a
    echo "compile arm64-v8a things..."
else
    ABI=armeabi-v7a
    echo "compile armeabi-v7a things..."
fi

NDK="/opt/android-sdk/ndk/${ndk_version}"
export ANDROID_NDK_HOME=$NDK
export PATH="$PATH:$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"
LIBS_ROOT=`pwd`

if [[ $ABI == arm64-v8a ]]
then
    export CC="aarch64-linux-android29-clang"
    export CCX="aarch64-linux-android29-clang++"
    export GOARCH=arm64
else
    export CC="armv7a-linux-androideabi16-clang"
    export CCX="armv7a-linux-androideabi16-clang++"
    export GOARCH=arm
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

git clone --single-branch --branch $snowflake_version https://github.com/keroserene/snowflake
cd snowflake/proxy/

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

if [[ $ABI == arm64-v8a ]]
then
    #compile arm64-v8a things...
    export APP_ABI=arm64
    NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make clean
    NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make
    NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make showsetup
else
    #compile armeabi-v7a things...
    export APP_ABI=armeabi
    make clean
    make
    make showsetup
fi

mv ../tor-android-binary/src/main/libs/${APP_ABI}/libtor.so ${LIBS_ROOT}/${ABI}/libtor.so

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

git clone --single-branch --branch $i2pd_version https://github.com/PurpleI2P/i2pd.git

export TARGET_I2P_ABI=$ABI
export APP_ABI=$ABI

if [[ $ABI == arm64-v8a ]]
then
    #compile arm64-v8a things...
    export TARGET_I2P_PLATFORM=21
    NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make clean
    NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make
    NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make showsetup
else
    #compile armeabi-v7a things...
    export TARGET_I2P_PLATFORM=16
    make clean
    make
    make showsetup
fi

mv ../i2pd-android-binary/src/main/libs/${APP_ABI}/libi2pd.so ${LIBS_ROOT}/${ABI}/libi2pd.so

cd $LIBS_ROOT
