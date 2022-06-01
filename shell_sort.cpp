#include <iostream>

void shell_sort(char a[], int length)
{
  int gap = length / 2;
  do
  {
    std::cout << "gap = " << gap << std::endl;
    for(int ii = 0; ii < gap; ii++)
    {
      std::cout << "ii = " << ii << std::endl;
        for(int i = ii; i < length; i = i + gap)
        {
          std::cout << "i = " << i << " a[i] = " << a[i] << std::endl;
          if(a[i] < a[i - gap])
          {
            std::cout << "insert" << std::endl;
            int t = a[i], j = i;
            for(; a[j] < a[j - gap]; j = j - gap)
              a[j] = a[j - gap];

            a[j] = t;
          }
        }
    }
    gap = gap / 2;
  }
  while(gap != 0);
}

int main ()
{
  char a[11] = {'0', '2', '1', '4', '3', '5', '7', '6', '8', '9', 0};
  std::cout << a << std::endl;
  shell_sort(a, 10);
  std::cout << a << std::endl;

  return 0;
}
