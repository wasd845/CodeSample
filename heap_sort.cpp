#include <iostream>

void adjust_heap(char a[], int pos, int length)
{
  if(length < 2)
    return;

  int lchild = 2 * pos + 1;
  if(lchild > length - 1)
    return;
  int rchild = (2 * pos + 2) > length - 1 ? lchild : (2 * pos + 2);
  int child = a[lchild] > a[rchild] ? lchild : rchild; 
  if(a[pos] > a[lchild] && a[pos] > a[rchild])
    return;

  a[pos] = a[child] + a[pos];
  a[child] = a[pos] - a[child];
  a[pos] = a[pos] - a[child];

  adjust_heap(a, child, length);
}

void adjust_heap2(char a[], int pos, int length)
{
  int parent = pos;
  char t = a[pos];
  for(int child = 2 * parent + 1; child < length;)
  {
    if(child < length - 1 && a[child + 1] > a[child])
      child++;
    if(t > a[child])
    {
      break;
    }
    a[parent] = a[child];
    parent = child;
    child = 2 * parent + 1;
  }
  a[parent] = t;
}

void heap_sort(char a[], int length)
{
  for(int i = length / 2 - 1; i >= 0; i--)
  {
    // adjust_heap(a, i, length);
    adjust_heap2(a, i, length);
  }

  for(int i = length; i > 1; i--)
  {
    a[0] = a[0] + a[i - 1];
    a[i - 1] = a[0] - a[i - 1];
    a[0] = a[0] - a[i - 1];

    // adjust_heap(a, 0, i - 1);
    adjust_heap2(a, 0, i - 1);
  }
}

int main ()
{
  char a[11] = {'0', '2', '1', '4', '3', '5', '7', '6', '8', '9', 0};
  std::cout << a << std::endl;
  heap_sort(a, 10);
  std::cout << a << std::endl;

  return 0;
}
