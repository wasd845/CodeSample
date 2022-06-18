#include <iostream>

//char* s = "sssssssssssssssssss";
#define s "ssssssssss"
#define f(name) f##name
int f(s)(int a)
{
    std::cout << a << std::endl;

    return a;

}

int main()
{
    f(s)(4);
    std::cout << "ssss44444"(s) << std::endl;


    return 0;

}