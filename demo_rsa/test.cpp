#include "alt_up_pci_lib.h"
#include <cstdlib>
#include <cstdio>
#include <cassert>
#include <chrono>
#include <cstring>
#include <memory>
using namespace std;

// PCIe DMA test
int test2(int fd) {
	const int chunk_size = 64;
	const int pcie_size  = 4096;
	char set_flag = 1;
	char read_flag= 1;
	
	unique_ptr<char[]> data_i (new char[pcie_size]);
	unique_ptr<char[]> data_o (new char[pcie_size]);
	unique_ptr<char[]> data_m (new char[pcie_size]);
	
	FILE *fin_dn = fopen("dn.txt", "rb");
	FILE *fin_c  = fopen("c.txt", "rb");
	FILE *fin_m  = fopen("m.txt", "rb");
	fread(data_i.get(), 1, chunk_size, fin_dn);
	fseek(fin_dn, 2, SEEK_CUR);// work for CRLF
	fread(data_i.get(), 1, chunk_size, fin_dn);
	
	for (int i = 0; i < 10; ++i) {
		fread(data_i.get(), 1, chunk_size, fin_c);
		fseek(fin_c, 2, SEEK_CUR);// work for CRLF
	}
	for (int i = 0; i < 10; ++i) {
		fread(data_m.get(), 1, chunk_size, fin_m);
		fseek(fin_c, 2, SEEK_CUR);// work for CRLF
	}
	
	const int irqHandling = POLLING;
	const int dmaId = 0;
	
	int addr = 0;
	assert(alt_up_pci_dma_add(fd, dmaId, addr, (char*)data_i.get(), pcie_size, TO_DEVICE) == 0);
	assert(alt_up_pci_dma_go(fd, dmaId, irqHandling) == 0);
	
	assert(alt_up_pci_write(fd, 2, 0, &set_flag, sizeof(set_flag)) == 0);
	while (read_flag == 1){
		assert(alt_up_pci_read(fd, 2, 0, &read_flag, sizeof(read_flag)) == 0);
	}
	
	// read
	int ndiff = 0;
	addr = 0;
	assert(alt_up_pci_dma_add(fd, dmaId, addr, (char*)data_o.get(), pcie_size, FROM_DEVICE) == 0);
	assert(alt_up_pci_dma_go(fd, dmaId, irqHandling) == 0);
	for (int j = 0; j < 1024; ++j) {
		if (data_o.get()[j] !=  data_m.get()[j]) {
			++ndiff;
		}
		printf("[w] %08x %c%c\n", addr+j, data_o.get()[j], data_m.get()[j]);
	}//printf("read speed %.2lfMB/s\n", ((nData*nBatch)>>18)/toc());

	return ndiff;
}

int main() {

	int fd;
	char dev[] = "/dev/alt_up_pci0";
	assert(alt_up_pci_open(&fd, dev) == 0);

	printf("%d\n", test2(fd));

	alt_up_pci_close(fd);
	return 0;
}
