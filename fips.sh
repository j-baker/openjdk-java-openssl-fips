#!/bin/bash -e

# Versions to build
opensslfips=$OPENSSL_FIPS_MODULE
opensslcore=$OPEN_SSL_CORE

# Update Ubuntu packages and ensure build tools are installed
apt-get -y update
apt-get -y install build-essential python

# Create a working directory
mkdir -p dist
cd dist

# Download source code packages
curl -sk "https://www.openssl.org/source/$opensslfips.tar.gz" > "$opensslfips.tar.gz"
curl -sk "https://www.openssl.org/source/$opensslcore.tar.gz" > "$opensslcore.tar.gz"

# Verify packages downloaded successfully
echo "$(curl -k https://www.openssl.org/source/$opensslfips.tar.gz.sha256) $opensslfips.tar.gz" > openssl-checksums.sha256
echo "$(curl -k https://www.openssl.org/source/$opensslcore.tar.gz.sha256) $opensslcore.tar.gz" >> openssl-checksums.sha256
sha256sum -c openssl-checksums.sha256

# Unpack packages
tar xzvf "$opensslfips.tar.gz"
tar xzvf "$opensslcore.tar.gz"

# Build the FIPS module first
pushd "$opensslfips"
  ./config
  make
  make install
popd

# Then build OpenSSL with FIPS support
pushd "$opensslcore"
  ./config fips shared
  make -j $(nproc)
  make install
popd

# Make the built OpenSSL binary the default one for the system
update-alternatives --force --install /usr/bin/openssl openssl /usr/local/ssl/bin/openssl 50
