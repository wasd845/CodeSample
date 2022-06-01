#include <stdio.h>
#include <iostream>

class Node {
    public:
    Node(int data);

    int data;

    Node* next;
    };
    
    class List {
    public:

    List();

    virtual ~List();

    Node* head();

    void setHead(Node* head);

    void addNode(Node* node, int pos = -1);

    void deleteNode(Node* node);

    void deleteNode(int pos);

    private:
    Node* p_head;

};

Node::Node(int data)
: data(data)
, next(NULL)
{

}

List::List()
{
    p_head = NULL;
}

List::~List()
{

}

Node* List::head()
{
    return p_head;
}

void List::setHead(Node* head)
{
    p_head = head;
    return;
}

void List::addNode(Node* node, int pos)
{
    int p = 0;
    if(head() == NULL)
    {
        p_head = node;
        return;
    }
        
    if(pos == 0 && head() != NULL)
    {
        Node* t = head();
        p_head = node;
        head()->next = t;
        return;
    }

    for(Node* h = head(); h != NULL; h = h->next, p++)
    {
        if(p == pos - 1)
        {
            Node* t = h->next;
            h->next = node;
            node->next = t;
            return;
        }
        if(pos == -1 && h->next == NULL)
        {
            h->next = node;
            return;
        }
    }
}

void List::deleteNode(Node* node)
{
    if(node->data == head()->data)
    {
        p_head = head()->next;
        return;
    }
    for(Node* p = head(); p != NULL && p->next != NULL; p = p->next)
    {
        if(p->next->data == node->data)
        {
            p->next = p->next->next;
            return;
        }
    }
}

void List::deleteNode(int pos)
{
    int p = 0;
    if(pos == 0)
    {
        p_head = head()->next;
        return;
    }

    for(Node* h = head(); h != NULL && h->next != NULL; h = h->next, p++)
    {
        if(p == pos - 1)
        {
            h->next = h->next->next;
            return;
        }
    }
}

const char* strcpy(const char* src, char* dest)
{
    auto t = src;
    if(!src || !dest)
        return NULL;

    while(*src != '\0')
        *dest++ = *src++;

    *dest = '\0';

    return t;
}

int main()
{
    List* list = new List();

    std::cout << "*****************" <<std::endl;

    for(int i = 0; i < 10; i++)
        list->addNode(new Node(i));

    std::cout << "*****************" <<std::endl;

    for(Node* p = list->head(); p != NULL; p = p->next)
        std::cout << p->data << std::endl;

    std::cout << "*****************" <<std::endl;

    list->deleteNode(new Node(4));
    list->deleteNode(new Node(8));

    std::cout << "*****************" <<std::endl;

    list->addNode(new Node(33), 6);
    list->addNode(new Node(82), 0);
    list->addNode(new Node(81), 0);

    for(Node* p = list->head(); p != NULL; p = p->next)
        std::cout << p->data << std::endl;

    std::cout << "*****************" <<std::endl;
    char src[] = "0 1 2 3 4 5 6 7 8 9";
    char dest[256] = {0};

    std::cout << src << std::endl;

    printf("%s\n", dest);

    strcpy(src, dest);

    std::cout << src << std::endl;

    std::cout << dest << std::endl;

    return 0;
}