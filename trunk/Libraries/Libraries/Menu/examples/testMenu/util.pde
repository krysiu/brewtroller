int availableMemory() {   int size = 4096;   byte *buf;   while ((buf = (byte *) malloc(--size)) == NULL);   free(buf);   return size; } 
