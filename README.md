# Kuznyechik

This repository contains the implementation of the Kuznyechik block cipher in the ECB mode. It is written in assembly.

This repository was tested in the Linux environment.
However, we use specialized functions available on Intel CPUs. Specific hardware is required. Before launching, check if your CPU supports SSE instructions and AES-NI.

# Scripts
The following command is used for building and testing of our solution.
```
./build-and-test.sh
```

The following command is used for building and testing of the aesni examples.
```
cd aesni-examples && ./build-and-test.sh
```

If everything worked fine, you should be able to run the comparison test.
This test took ~10 minutes to finish.
The way of passing keys and data can be found in `test_speed.sh`.
Check the function `benchmark_kuznyechik`. 
```
./test_speed.sh
```

Our results can be found in the `test_speed.log`.

# References
## Kuznyechik (Python)
We used the following implenetation of [Kuznyechik in Python](https://github.com/jacksoninfosec/kuznyechik) to speed up the development.

## Comparison with AES-NI
We use the following implementation of [AES with hardware acceleration in the ECB mode.](https://github.com/kmcallister/aesni-examples)
