#include <iostream>

void select_sort(char a[], int length)
{
  for(int i = 0; i < length; i++)
  {
    for(int j = i + 1; j < length; j++)
    {
      if(a[i] > a[j])
      {
        a[i] = a[i] + a[j];
        a[j] = a[i] - a[j];
        a[i] = a[i] - a[j];
      }
    }
  }
}

int main ()
{
  char a[11] = {'0', '2', '1', '4', '3', '5', '7', '6', '8', '9', 0};
  std::cout << a << std::endl;
  select_sort(a, 10);
  std::cout << a << std::endl;

  return 0;
}