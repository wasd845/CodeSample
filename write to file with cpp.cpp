#include <sstream>

std::ofstream outf(str_filepath.c_str(), std::ofstream::binary | std::ofstream::out);
if(outf.rdstate() & std::ofstream::failbit)
    return;

outf.write(reinterpret_cast<const char*>(p_data), u_size);
outf.close();