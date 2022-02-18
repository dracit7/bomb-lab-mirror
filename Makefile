# .PHONY: gdb qemu qemu-gdb

qemu: 
	qemu-aarch64 ./bomb

qemu-gdb: 
	qemu-aarch64 -g 1234 ./bomb

gdb:
	gdb-multiarch -ex "set architecture aarch64" -ex "target remote localhost:1234" -ex "add-symbol-file bomb"
