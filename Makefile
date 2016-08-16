CFLAGS += -g
LDFLAGS += -framework Hypervisor

SRCS := \
	src/main.c\
	src/debug.c\
	src/syscall/common.c\
	src/syscall/fs.c\
	src/syscall/exec.c\
	src/syscall/process.c\
	src/syscall/mm.c\
	src/syscall/signal.c\
	src/sandbox.c

TEST_UPROGS := \
	$(addprefix test/test_assertion/build/, fib)\
	$(addprefix test/test_stdout/build/, hello cat echo)\
	$(addprefix test/test_shell/build/, mv env)

all: build/noah

dev: CFLAGS += -DDEBUG_MODE=1
dev: build/noah

build/noah: $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

test/test_assertion/build/%: test/test_assertion/%.c test/include/*.h test/include/noah.S
	$(MAKE_TEST_UPROGS)
test/test_stdout/build/%: test/test_stdout/%.c test/include/*.h test/include/noah.S
	$(MAKE_TEST_UPROGS)
test/test_shell/build/%: test/test_shell/%.c test/include/*.h test/include/noah.S
	$(MAKE_TEST_UPROGS)

MAKE_TEST_UPROGS = rsync $^ idylls.jp:/tmp/$(USER)/;\
                   ssh idylls.jp "gcc -nostdlib -static /tmp/$(USER)/$*.c /tmp/$(USER)/noah.S -o /tmp/$(USER)/$*";\
                   rsync idylls.jp:/tmp/$(USER)/$* $@

run: build/noah test/test_stdout/build/hello
	./build/noah test/test_stdout/build/hello
clean:
	$(RM) -r src/*.o
	$(RM) -r src/syscall/*.o
	$(RM) -r build/noah
	$(RM) test/test_assertion/build/* test/test_stdout/build/* test/test_shell/build/*

test: build/noah $(TEST_UPROGS)
	./test/test.rb

.PHONY: all run test clean
