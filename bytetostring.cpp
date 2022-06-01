void tool::print_ascii( unsigned char *pp,  int len)
{
    std::string s;
    for(int i = 0; i < len; i++)
    {
        char c[5] = {0};
        sprintf(c, "%02x ", pp[i]);
        s += c;
    }
    VOLOGI("size:%d, ascii:%s", len, s.c_str());
}