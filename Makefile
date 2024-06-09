
export NDK_ROOT=/home/android-ndk-r25b
export PATH=$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:/usr/local/go/bin:/usr/bin:$PATH


BUILD_TAGS := -tags forarm
CMD_GO := go


GO_RUN = go run github.com/cilium/ebpf/cmd/bpf2go
GO_MOD_TIDY = go mod tidy
GO_BUILD = go build
TARGET = arm64
PACKAGE = main
TYPE = event
BPF_FILE = binder_transaction.byte.c
HEADERS = ./headers
BPF_OUTPUT = bpf
BINARY_NAME = btrace

all: bpf tidy build

bpf:
	$(GO_RUN) -go-package $(PACKAGE) --target=$(TARGET) -type $(TYPE) $(BPF_OUTPUT) $(BPF_FILE) -- -I$(HEADERS)

tidy:
	$(GO_MOD_TIDY)

build: tidy
	GOARCH=arm64 GOOS=android CGO_ENABLED=1 CC=aarch64-linux-android29-clang $(CMD_GO) build $(BUILD_TAGS) -o $(BINARY_NAME)   main.go method_resolver.go package_resolver.go parcel_parser.go bpf_arm64_bpfel.go

clean:
	rm -f $(BPF_OUTPUT)_$(TARGET)_bpfel.go $(BPF_OUTPUT)_$(TARGET)_bpfel.o $(BINARY_NAME)

.PHONY: all bpf tidy build clean
