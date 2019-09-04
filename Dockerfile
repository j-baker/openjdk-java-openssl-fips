FROM openjdk:8-jdk
ENV OPENSSL_FIPS_MODULE openssl-fips-2.0.12
ENV OPEN_SSL_CORE openssl-1.0.2h
ADD fips.sh /
RUN ./fips.sh
RUN /bin/bash -c "ln -s /usr/local/ssl/lib/libcrypto.so /usr/lib/ssl/libcrypto.so"
