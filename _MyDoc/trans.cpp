#include "bmp.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

using namespace std;

vector<string> s = {"B2", "B4", "B8", "B16", "B32", "B64", "B128", "B256", "B512", "B1024" /*, "B2048"*/};

int main() {
    U8 bitCountPerPix;
    U32 width, height;
    int kk = 1;
    for (int i = 0; i < s.size(); i++) {
        U8 *pdata = GetBmpData24(&bitCountPerPix, &width, &height, (s[i] + string(".bmp")).c_str());
        printf("%d %d\n", width, height);
        ofstream fout(s[i] + string(".coe"));
        int x, y;
        U32 bmppitch    = ((width * bitCountPerPix + 31) >> 5) << 2;
        U8 BytePerPix   = bitCountPerPix >> 3;
        U32 pitch       = width * BytePerPix;
        U32 originpitch = width * BytePerPix;
        fout << "memory_initialization_radix=16;" << endl;
        fout << "memory_initialization_vector=" << endl;
        for (y = 0; y < height; y++) {
            for (x = 0; x < width; x++) {
                int data = pdata[y * originpitch + x * BytePerPix + 2] / 16;
                char tmp[4];
                sprintf(tmp, "%01X", data);
                fout << tmp;
                data = pdata[y * originpitch + x * BytePerPix + 1] / 16;
                sprintf(tmp, "%01X", data);
                fout << tmp;
                data = pdata[y * originpitch + x * BytePerPix + 0] / 16;
                sprintf(tmp, "%01X", data);
                fout << tmp;
                fout << ", ";
            }
            fout << endl;
        }
        free(pdata);
    }
    return 0;
}
