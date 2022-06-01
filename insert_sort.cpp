#include <iostream>

void insert_sort(char a[], int length)
{
  for(int i = 1; i < length; i++)
  {
    if(a[i] < a[i - 1])
    {
      int t = a[i], j = i;
      for(; a[j] < a[j - 1]; j--)
        a[j] = a[j - 1];

      a[j] = t;
    }
  }
}

void insert_sort2(char a[], int length)
{
  for(int i = 1; i < length; i++)
  {
    int t = a[i];
    for(int j = i; j > 0; j--)
    {
      if(t <= a[j] && t > a[j - 1])
      {
        a[j] = t;
        break;
      }
      a[j] = a[j - 1];
    }
  }
}

int main ()
{
  char a[11] = {'0', '2', '1', '4', '3', '5', '7', '6', '8', '9', 0};
  std::cout << a << std::endl;
  // insert_sort(a, 10);
  insert_sort2(a, 10);
  std::cout << a << std::endl;

  return 0;
}