#!/usr/bin/python3

K =  0.25 * (2 ** 30) / (10 ** 6)

print("0.25 GiB = {} MB".format(K))

Tae = 34.184
Tad = 33.719

Kue = 3 * 60 + 39.856
Kud = 3 * 60 + 39.335

print("* Real time")
def throughput(x):
    return K / x

print("** AES-NI Encryption    : {} (MB/s)".format(round(throughput(Tae), 3)))
print("** AES-NI Decryption    : {} (MB/s)".format(round(throughput(Tad), 3)))

print("** Kuznyechik Encryption: {} (MB/s)".format(round(throughput(Kue), 3)))
print("** Kuznyechik Decryption: {} (MB/s)".format(round(throughput(Kud), 3)))

print("* User time")
Tae = 10.644
Tad = 10.940

Kue = 3 * 60 + 14.774
Kud = 3 * 60 + 14.359

throughputTae = throughput(Tae)
throughputKue = throughput(Kue)
print("** AES-NI Encryption    : {} (MB/s)".format(round(throughputTae, 3)))
print("** AES-NI Decryption    : {} (MB/s)".format(round(throughput(Tad), 3)))



print("** Kuznyechik Encryption: {} (MB/s)".format(round(throughputKue, 3)))
print("** Kuznyechik Decryption: {} (MB/s)".format(round(throughput(Kud), 3)))

print("* Other")
print("** AES-NI: ~{}x".format(round(throughputTae/throughputKue, 0)))
print("** Optim : ~{}x".format(round(170/throughputKue, 0)))
print("** Nvidia: ~{}x".format(round(30000/throughputKue, 0)))
