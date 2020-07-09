#include <iostream>

int main(int argc, char const *argv[]) {
    using namespace std;
    const int SLOT_WIDTH  = 16;
    const int BLOCK_WIDTH = 100;
    int X_Addr = -1, Y_Addr = -1, X_BlockID = -1, Y_BlockID = -1;
    while (cin >> X_Addr >> Y_Addr) {
        for (int i = 0; i < 4; i = i + 1) {
            if (SLOT_WIDTH * (i + 1) + BLOCK_WIDTH * i <= X_Addr && X_Addr < (SLOT_WIDTH + BLOCK_WIDTH) * (i + 1))
                X_BlockID = i;

            if (SLOT_WIDTH * (i + 1) + BLOCK_WIDTH * i <= Y_Addr && Y_Addr < (SLOT_WIDTH + BLOCK_WIDTH) * (i + 1))
                Y_BlockID = i;
        }
        int Y_Len = BLOCK_WIDTH - 1 - (Y_Addr - SLOT_WIDTH * (Y_BlockID + 1) - BLOCK_WIDTH * Y_BlockID),
            X_Len = X_Addr - SLOT_WIDTH * (X_BlockID + 1) - BLOCK_WIDTH * X_BlockID;
        cout << X_BlockID << " " << Y_BlockID << " " << X_Len << " " << Y_Len << " "
             << (Y_Len / 2) * BLOCK_WIDTH / 2 + X_Len / 2 << endl;
    }
    return 0;
}
