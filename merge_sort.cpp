#include <iostream>

void merge(char a[], int L, int R, int RightEnd)
{
  int i = L, j = R, ati = 0;
  char* at = new char[RightEnd - L + 1]();

  // while(i <= R && j <= RightEnd) //infinite loop
  // {
  //   while(a[i] < a[j] && i < R)
  //   {
  //     at[ati++] = a[i];
  //     i++;
  //   }
  //   while(a[j] < a[i] && j <= RightEnd)
  //   {
  //     at[ati++] = a[j];
  //     j++;
  //   }
  // }

  while(i < R && j <= RightEnd)
  {
    if(a[i] < a[j])
    {
      at[ati++] = a[i++];
    }
    else
    {
      at[ati++] = a[j++];
    }
  }
  while(i < R)
  {
    at[ati++] = a[i++];
  }
  while(j <= RightEnd)
  {
    at[ati++] = a[j++];
  }

  for(int i = L, j = 0; i <= RightEnd ; i++)
  {
    a[i] = at[j++];
  }
}

void merge_sort(char a[], int L, int RightEnd)
{
  int Center = (L + RightEnd) / 2;
  if(L < RightEnd)
  {
    merge_sort(a, L, Center);
    merge_sort(a, Center + 1, RightEnd);
    merge(a, L, Center + 1, RightEnd);
  }
}

int main ()
{
  char a[11] = {'0', '2', '1', '4', '3', '5', '7', '6', '8', '9', 0};
  std::cout << a << std::endl;
  merge_sort(a, 0, 10 - 1);
  std::cout << a << std::endl;

  return 0;
}
