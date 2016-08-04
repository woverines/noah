ASFLAGS += -m32
CFLAGS += -g
LDFLAGS += -framework Hypervisor

all: build/noah

dev: CFLAGS += -DDEBUG_MODE=1
dev: build/noah

build/noah: src/main.o src/debug.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

_%: user/%.c user/noah.h
	rsync $^ user/noah.h idylls.jp:/tmp/
	ssh idylls.jp "gcc -nostdlib -static /tmp/$*.c -o /tmp/$@"
	rsync idylls.jp:/tmp/$@ ./$@

run: build/noah _hello
	./build/noah _hello

clean:
	$(RM) -r src/*.o
	$(RM) -r build/noah
	$(RM) _*

.PHONY: all run clean
