#!/bin/bash

############
## Config ##
############

obfs4proxy_url=https://github.com/Yawning/obfs4
obfs4proxy_version=obfs4proxy-0.0.11
dnscryptproxy_url=https://github.com/DNSCrypt/dnscrypt-proxy
dnscryptproxy_version=2.0.44
snowflake_url=https://github.com/keroserene/snowflake
snowflake_version=7043a055f9fb0680281ecffd7d458a43f2ce65b5
openssl_url=https://github.com/openssl/openssl.git
tor_openssl_version=OpenSSL_1_1_1h
i2pd_openssl_version=OpenSSL_1_1_1g
libevent_url=https://github.com/libevent/libevent.git
libevent_version=release-2.1.11-stable
zstd_url=https://github.com/facebook/zstd.git
zstd_version=v1.4.5
xz_url=https://git.tukaani.org/xz.git
xz_version=v5.2.3
tor_url=https://git.torproject.org/tor.git
tor_version=release-0.4.4

NDK="$ANDROID_NDK"
export PATH="$PATH:$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"

CCX_armv7a="armv7a-linux-androideabi16-clang++"
CC_armv7a="armv7a-linux-androideabi16-clang"
CCX_aarch64="aarch64-linux-android29-clang++"
CC_aarch64="aarch64-linux-android29-clang"

export CGO_ENABLED=1
export GOOS="android"

##############
##############

# Clean
rm -r -f arm64-v8a armeabi-v7a obfs4proxy dnscrypt snowflake
mkdir arm64-v8a armeabi-v7a

#################
# libobfs4proxy #
#################

git clone $obfs4proxy_url -b $obfs4proxy_version obfs4proxy
cd obfs4proxy/obfs4proxy/

#compile arm64-v8a things...
export CC=$CC_aarch64
export CCX=$CCX_aarch64
export GOARCH=arm64
go build -ldflags="-s -w" -o libobfs4proxy.so
mv libobfs4proxy.so ../../arm64-v8a/libobfs4proxy.so

#compile armeabi-v7a things...
export CC=$CC_armv7a
export CCX=$CCX_armv7a
export GOARCH=arm
go clean
go build -ldflags="-s -w" -o libobfs4proxy.so
mv libobfs4proxy.so ../../armeabi-v7a/libobfs4proxy.so

cd ../..

#####################
# libdnscrypt-proxy #
#####################

git clone $dnscryptproxy_url -b $dnscryptproxy_version dnscrypt
cd dnscrypt/dnscrypt-proxy/

#compile arm64-v8a things...
export CC=$CC_aarch64
export CCX=$CCX_aarch64
export GOARCH=arm64
go build -ldflags="-s -w" -o libdnscrypt-proxy.so
mv libdnscrypt-proxy.so ../../arm64-v8a/libdnscrypt-proxy.so

#compile armeabi-v7a things...
export CC=$CC_armv7a
export CCX=$CCX_armv7a
export GOARCH=arm
go clean
go build -ldflags="-s -w" -o libdnscrypt-proxy.so
mv libdnscrypt-proxy.so ../../armeabi-v7a/libdnscrypt-proxy.so

cd ../..

################
# libsnowflake #
################

git clone $snowflake_url snowflake
cd snowflake/
git checkout -f $snowflake_version -b $snowflake_version
cd proxy/

#compile arm64-v8a things...
export CC=$CC_aarch64
export CCX=$CCX_aarch64
export GOARCH=arm64
go build -ldflags="-s -w" -o libsnowflake.so
mv libsnowflake.so ../../arm64-v8a/libsnowflake.so

#compile armeabi-v7a things...
export CC=$CC_armv7a
export CCX=$CCX_armv7a
export GOARCH=arm
go clean
go build -ldflags="-s -w" -o libsnowflake.so
mv libsnowflake.so ../../armeabi-v7a/libsnowflake.so

cd ../..

##########
# libtor #
##########

cd ../../TorBuildScript/external/
export EXTERNAL_ROOT=`pwd`/external

git clone --single-branch --branch tor_openssl_version openssl_url
git clone --single-branch --branch libevent_version libevent_url
git clone --single-branch --branch zstd_version zstd_url
git clone --single-branch --branch xz_version xz_url
git clone --single-branch --branch tor_version tor_url

#compile arm64-v8a things...
#android r20 22 default arm64-v8a
APP_ABI=arm64 NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make clean
APP_ABI=arm64 NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make
APP_ABI=arm64 NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make showsetup
mv ../tor-android-binary/src/main/libs/armeabi/libtor.so ../../tordnscrypt/libs/arm64-v8a/libtor.so

#compile armeabi-v7a things...
#android r20 22 default armeabi-v7a
APP_ABI=armeabi make clean
APP_ABI=armeabi make
APP_ABI=armeabi make showsetup
mv ../tor-android-binary/src/main/libs/armeabi/libtor.so ../../tordnscrypt/libs/armeabi-v7a/libtor.so

cd ../../tordnscrypt/libs/

###########
# libi2pd #
###########

cd ../../PurpleI2PBuildScript/external/

    - export TARGET_I2P_ABI=`echo $CI_JOB_NAME | awk '{print $5}'`
    - export TARGET_I2P_PLATFORM=`echo $CI_JOB_NAME | awk '{print $3}'`

mkdir -p libs
export EXTERNAL_ROOT=`pwd`/external

cd libs/
git clone --single-branch --branch i2pd_openssl_version openssl_url
git clone https://github.com/moritz-wundke/Boost-for-Android.git
git clone https://github.com/miniupnp/miniupnp.git
git clone https://github.com/PurpleI2P/android-ifaddrs.git
cd ../

git clone https://github.com/PurpleI2P/i2pd.git

#compile arm64-v8a things...
#android r20b 21 default arm64-v8a:
APP_ABI=arm64-v8a NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make clean
APP_ABI=arm64-v8a NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make
APP_ABI=arm64-v8a NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make showsetup
mv ../i2pd-android-binary/src/main/libs/arm64-v8a/libi2pd.so ../../tordnscrypt/libs/arm64-v8a/libi2pd.so

#compile armeabi-v7a things...
#android r20b 16 default armeabi-v7a:
APP_ABI=armeabi-v7a make clean
APP_ABI=armeabi-v7a make
APP_ABI=armeabi-v7a make showsetup
mv ../i2pd-android-binary/src/main/libs/armeabi-v7a/libi2pd.so ../../tordnscrypt/libs/armeabi-v7a/libi2pd.so
