#!/bin/bash

mkdir -p out
echo "* Generating data..."
openssl rand -out out/aes_key.bin $(( 16 ))
openssl rand -out out/kuz_key.bin $(( 16 * 2 ))
openssl rand -out out/sample.bin $(( 16 * 2 ** 24 )) # 0.25 GB

echo "* Size of data"
du -h --apparent-size -B 1 out/sample.bin
# cat out/sample.bin | xxd -p

benchmark_aes() {
    echo "* AES"
    echo "** Key"
    cat out/aes_key.bin | xxd -p

    echo "** Encryption..."
    time cat out/aes_key.bin out/sample.bin | ./aesni-examples/encrypt > out/aes_encrypted.bin
    # cat out/encrypted.bin | xxd -p

    echo "** Decryption..."
    time cat out/aes_key.bin out/aes_encrypted.bin | ./aesni-examples/decrypt > out/aes_decrypted.bin

    echo "** Comparison..."
    diff <(xxd -p out/sample.bin) <(xxd -p out/aes_decrypted.bin)
    if [[ "$?" -ne "0" ]]; then
        echo "Error"
    else
        echo "OK"
    fi
}

benchmark_kuznyechik() {
    echo "* Kuznyechik"

    echo "** Key"
    cat out/kuz_key.bin | xxd -p

    echo "** Encryption..."
    time cat out/kuz_key.bin out/sample.bin | ./kuznyechik-encrypt > out/kuz_encrypted.bin
    # cat out/kuz_encrypted.bin | xxd -p

    echo "** Decryption..."
    time cat out/kuz_key.bin out/kuz_encrypted.bin | ./kuznyechik-decrypt > out/kuz_decrypted.bin

    echo "** Comparison..."
    diff <(xxd -p out/sample.bin) <(xxd -p out/kuz_decrypted.bin)
    if [[ "$?" -ne "0" ]]; then
        echo "Error"
    else
        echo "OK"
    fi
}

benchmark_aes
benchmark_kuznyechik

echo "* File sizes (in bytes)..."
du -h --apparent-size -B 1 out/*
