#!/bin/python3

Tae = 43.497
Tad = 45.382

Kue = 4 * 60 + 42.351
Kud = 4 * 60 + 33.868

def throughput(x):
    return 0.25 * 1024 / x

print("AES-NI Encryption: {} (MiB/s)".format(throughput(Tae)))
print("AES-NI Decryption: {} (MiB/s)".format(throughput(Tad)))

print("Kuznyechik Encryption: {} (MiB/s)".format(throughput(Kue)))
print("Kuznyechik Decryption: {} (MiB/s)".format(throughput(Kud)))