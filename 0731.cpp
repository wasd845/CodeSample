#include <stdio.h>
 
void Q(int a[],int n);
int  main()
 {
    Q((int []){0,1,2},3);     //使用数组复合字面值！不用先声明数组，如：int a[3];
 }
  
void Q(int a[],int n)
 {
   int i;
   for(i=0;i<n;i++)
    printf("%d\n",a[i]);
 } 
