#!/bin/bash

if [ -f ./example_files/encoded-lzss ]; then
    rm ./example_files/encoded-lzss
fi

if [ -f ./example_files/decoded_lzss ]; then
    rm ./example_files/decoded_lzss
fi

zig build

./zig-out/bin/lzss-zig encode -t ./zig-out/bin/lzss-zig -o ./example_files/encoded-lzss

./zig-out/bin/lzss-zig decode -t ./example_files/encoded-lzss -o ./example_files/decoded_lzss

decoded_size=$(stat -f %z ./example_files/decoded_lzss)
zig_size=$(stat -f %z ./zig-out/bin/lzss-zig)

if [ $decoded_size -ne $zig_size ]; then
    echo "File sizes are different:"
    echo "Decoded Size: $decoded_size bytes"
    echo "lzss-zig Size: $zig_size bytes"
    
    diff_result=$(cmp ./example_files/decoded_lzss ./zig-out/bin/lzss-zig)

    echo "$diff_result"
else
    echo "File sizes are the same"
    exit 0
fi
