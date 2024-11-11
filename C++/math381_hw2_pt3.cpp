#include <iostream>

int main() {
    int n = 21;

    for (int i = 1; i <= n; ++i) {
        for (int k = 1; k <= n; ++k) {
            std::cout << "+x_" << i << "_" << k << " ";
        }
        std::cout << "= 2;" << std::endl;
    }

    return 0;
}