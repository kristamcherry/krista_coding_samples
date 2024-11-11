#include <iostream>
#include <vector>

int main() {
    int n = 21;
    std::vector<std::pair<int, int>> E = {
        {1, 2}, {1, 3}, {2, 3}, {2, 4}, {3, 4}, {3, 5}, {4, 5}, {4, 6}, {5, 6},
        {5, 9}, {6, 7}, {6, 9}, {6, 10}, {7, 10}, {7, 11}, {8, 9}, {9, 10}, {9, 12},
        {9, 13}, {10, 11}, {10, 13}, {10, 14}, {10, 17}, {10, 18}, {11, 14},
        {12, 13}, {12, 15}, {13, 15}, {13, 16}, {13, 17}, {14, 18}, {15, 16},
        {15, 19}, {16, 17}, {16, 19}, {16, 20}, {17, 18}, {17, 20}, {17, 21},
        {18, 21}, {19, 20}
    };

    //print objective function
    std::cout << "min: ";
    for (int i = 1; i < n; ++i) {
        std::cout << "y_" << i << " + ";
    }
    std::cout << "y_" << n << ";" << std::endl;

    //print constraints: sum of y_i >= 3
    for (int i = 1; i <= n; ++i) {
        std::cout << "+y_" << i << " ";
    }
    std::cout << ">= 3;" << std::endl;

    //print fixed variable y_1 = 1
    std::cout << "y_1 = 1;" << std::endl;

    //print constraints: each row sum of x_i_k = 2
    for (int i = 1; i <= n; ++i) {
        for (int k = 1; k <= n; ++k) {
            std::cout << "+x_" << i << "_" << k << " ";
        }
        std::cout << "= 2;" << std::endl;
    }

    //print constraints: x_i_k <= y_k
    for (int i = 1; i <= n; ++i) {
        for (int k = 1; k <= n; ++k) {
            std::cout << "x_" << i << "_" << k << " <= y_" << k << ";" << std::endl;
        }
    }

    //print constraints: x_i_k + x_j_k <= 1 for each edge (i, j) in E
    for (int k = 1; k <= n; ++k) {
        for (const auto& [i, j] : E) {
            std::cout << "x_" << i << "_" << k << " + x_" << j << "_" << k << " <= 1;" << std::endl;
        }
    }

    //print constraints: y_k <= y_(k-1) for k = 2 to n
    for (int k = 2; k <= n; ++k) {
        std::cout << "y_" << k << " <= y_" << (k - 1) << ";" << std::endl;
    }

    //print binary declaration for y variables
    std::cout << "bin ";
    for (int k = 1; k < n; ++k) {
        std::cout << "y_" << k << ", ";
    }
    std::cout << "y_" << n << ";" << std::endl;

    //print binary declaration for x variables
    std::cout << "bin ";
    for (int i = 1; i <= n; ++i) {
        for (int k = 1; k <= n; ++k) {
            if (k != n || i != n) {
                std::cout << "x_" << i << "_" << k << ", ";
            } else {
                std::cout << "x_" << n << "_" << n << ";" << std::endl;
            }
        }
    }

    return 0;
}

