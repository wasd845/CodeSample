#include <iostream>

void swap(char* c1, char* c2)
{
  char ct = *c1;
  *c1 = *c2;
  *c2 = ct;
}

int median(char a[], int lpos, int rpos)
{
  int m = (lpos + rpos) / 2;
  if(a[lpos] > a[m])
    swap(&a[lpos], &a[m]);

  if(a[lpos] > a[rpos])
    swap(&a[lpos], &a[rpos]);

  if(a[m] > a[rpos])
    swap(&a[m], &a[rpos]);

  return m;
}

void quick_sort(char a[], int lpos, int rpos)
{
  if(rpos - lpos < 2 && a[lpos] <= a[rpos])
    return;

  int pivot_pos = median(a, lpos, rpos);
  swap(&a[pivot_pos], &a[rpos]);

  for(;;)
  {
    int i = lpos, j = rpos - 1;
    while(a[i] < a[rpos])
    {
      i++;
    }
    while(a[j] > a[rpos])
    {
      j--;
    }
    if(i < j)
    {
      swap(&a[i], &a[j]);
    }
    else
    {
      swap(&a[i], &a[rpos]);
      pivot_pos = i;
      break;
    }
  }

  quick_sort(a, lpos, pivot_pos - 1);
  quick_sort(a, pivot_pos + 1, rpos);
}

int main ()
{
  char a[11] = {'0', '2', '1', '4', '3', '5', '7', '6', '8', '9', 0};
  std::cout << a << std::endl;
  quick_sort(a, 0, 10 - 1);
  std::cout << a << std::endl;

  return 0;
}
