#!/bin/bash

printf 'Building... '
for bin in multiplication transformL  transformS transformR key-schedule encrypt decrypt; do
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

test_multiplication() {
    printf "Testing multiplication... "
    ./kuznyechik-multiplication
    if [ "$?" -ne 0 ]; then
        printf "failed."
        exit 1
    else
        printf "done.\n"
    fi
}

test_transforms() {
    TEST_DIR="tests/"

    for transform in transformS transformR transformL; do
        echo "Testing $transform ..."
        FILE="${TEST_DIR}/${transform}.txt"
        while read -r input output; do
            result=$(echo "${input}" | xxd -r -p - | ./kuznyechik-${transform} | hexdump -v -e '16/1 "%02x" "\n"')
            if [[ "${result}" != "${output}" ]]; then
                printf "\nInput:${input}, Expected:${output}, Got:${result}\n"
                echo "failed."
                exit 1
            fi
            echo "${result} OK"
        done < "${FILE}"
    done
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
    cat ${TEST_DIR}/encryption.txt | while read -r  key input output; do
        result=$(echo "${key}${input}" | xxd -r -p - | ./kuznyechik-encrypt | hexdump -v -e '16/1 "%02x"')
        if [[ "${result}" != "${output}" ]]; then
            echo "Input:${input}, Expected:${output}, Got:${result}"
            echo "failed."
            exit 1
        fi
        echo "${result} OK"
    done
}

test_decryption() {
    echo 'Testing decryption... '
    TEST_DIR="tests"
    cat ${TEST_DIR}/decryption.txt | while read -r key input output; do
        result=$(echo "${key}${input}" | xxd -r -p - | ./kuznyechik-decrypt | hexdump -v -e '16/1 "%02x"')
        if [[ "${result}" != "${output}" ]]; then
            echo "Input:${input}, Expected:${output}, Got:${result}"
            echo "failed."
            exit 1
        fi
        echo "${result} OK"
    done
}

test_multiplication
test_transforms
test_key_schedule
test_encryption
test_decryption
