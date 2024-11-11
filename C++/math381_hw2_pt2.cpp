#include <iostream>
#include <vector>
#include <utility> // for std::pair
#include <algorithm> // for std::find

int main() {
    //define the initial edge list
    std::vector<std::pair<int, int>> E = {
        {1, 2}, {1, 3}, {2, 3}, {2, 4}, {3, 4}, {3, 5}, {4, 5}, {4, 6}, {5, 6},
        {5, 9}, {6, 7}, {6, 9}, {6, 10}, {7, 10}, {7, 11}, {8, 9}, {9, 10}, {9, 12},
        {9, 13}, {10, 11}, {10, 13}, {10, 14}, {10, 17}, {10, 18}, {11, 14},
        {12, 13}, {12, 15}, {13, 15}, {13, 16}, {13, 17}, {14, 18}, {15, 16},
        {15, 19}, {16, 17}, {16, 19}, {16, 20}, {17, 18}, {17, 20}, {17, 21},
        {18, 21}, {19, 20}
    };

    //create a copy of E
    std::vector<std::pair<int, int>> E_copy = E;

    //add additional edges to E based on conditions
    for (const auto& [i, j] : E_copy) {
        for (const auto& [k, m] : E_copy) {
            if (i == k && j < m) {
                if (std::find(E.begin(), E.end(), std::make_pair(j, m)) == E.end()) {
                    E.emplace_back(j, m);
                }
            }
            if (j == k && i < m) {
                if (std::find(E.begin(), E.end(), std::make_pair(i, m)) == E.end()) {
                    E.emplace_back(i, m);
                }
            }
        }
    }

    //print the modified E
    std::cout << "Modified edges in E:\n";
    for (const auto& edge : E) {
        std::cout << "(" << edge.first << ", " << edge.second << ")\n";
    }

    return 0;
}
