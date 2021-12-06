#!/bin/bash

printf 'Building... '
for bin in transformS key-schedule encrypt; do
    gcc -Wall -no-pie $bin.s -o kuznyechik-$bin
done
printf 'done.\n'

assert_equal_files() {
    diff $1 $2
    if [ "$?" -ne 0 ]; then
        printf "failed."
        exit 1
    else
        printf 'done.\n'
    fi
}

test_transform_S() {
    echo 'Testing transform S... '
    TEST_DIR="tests/"

    while read -r input output; do
        result=$(echo "${input}" | xxd -r -p - | ./kuznyechik-transformS | hexdump -v -e '16/1 "%02x" "\n"')
        if [[ "${result}" != "${output}" ]]; then
            printf "\nInput:${input}, Expected:${output}, Got:${result}\n"
            echo "failed."
            exit 1
        fi
        echo "${result} OK"
    done < ${TEST_DIR}/transformS.txt
    echo "done."
}

test_key_schedule() {
    printf 'Testing key schedule... '
    TEST_DIR="tests/key-schedule/"

    cat ${TEST_DIR}/input.txt | xxd -r -p - | ./kuznyechik-key-schedule | hexdump -v -e '16/1 "%02x" "\n"' > ${TEST_DIR}/generated_keys.txt
    assert_equal_files "${TEST_DIR}/output.txt" "${TEST_DIR}/generated_keys.txt"
}

test_encryption() {
    echo 'Testing encryption... '
    TEST_DIR="tests"
    cat ${TEST_DIR}/encryption.txt | read -r key input output
    result=$(echo "${key}${input}" | xxd -r -p - | ./kuznyechik-encrypt | hexdump -v -e '16/1 "%02x"')
    if [[ "${result}" != "${output}" ]]; then
        echo "\nInput:${input}, Expected:${output}, Got:${result}"
        echo "failed."
        exit 1
    fi
}

test_decryption() {
    echo 'Testing decryption... '
    TEST_DIR="tests"
    cat ${TEST_DIR}/decryption.txt | read -r key input output
    result=$(echo "${key}${input}" | xxd -r -p - | ./kuznyechik-decrypt | hexdump -v -e '16/1 "%02x"')
    if [[ "${result}" != "${output}" ]]; then
        echo "Input:${input}, Expected:${output}, Got:${result}"
        echo "failed."
        exit 1
    fi
}

test_transform_S
# test_key_schedule
# test_encryption
# test_decryption
