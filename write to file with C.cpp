#include <stdio.h>

FILE* fp1 = fopen("/path/filename","wb");
fwrite(Data,1,Size,fp1);
fclose(fp1);