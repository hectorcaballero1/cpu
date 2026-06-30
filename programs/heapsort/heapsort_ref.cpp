#include <iostream>
using namespace std;

// Indices del heap (raiz = 0):
//   hijo izquierdo de i  = 2*i + 1
//   hijo derecho de i    = 2*i + 2
//   padre de i           = (i - 1) / 2

void heapify_down(int arr[], int size, int i) {
    while (true) {
        int largest = i;          // x11 = i, x12 = largest
        int l = 2 * i + 1;        // hijo izquierdo  (x13)
        int r = 2 * i + 2;        // hijo derecho

        if (l < size && arr[l] > arr[largest]) largest = l;
        if (r < size && arr[r] > arr[largest]) largest = r;

        if (largest == i) return; // ya cumple max-heap, terminamos

        // swap arr[i] <-> arr[largest], luego bajamos un nivel
        int tmp = arr[i];
        arr[i] = arr[largest];
        arr[largest] = tmp;

        i = largest;              // i = largest  (continua el while)
    }
}

void heapify_up(int arr[], int i) {
    while (i > 0) {
        int parent = (i - 1) / 2;
        if (arr[i] <= arr[parent]) break; // ya cumple max-heap
        int tmp = arr[i];
        arr[i] = arr[parent];
        arr[parent] = tmp;
        i = parent; // sube un nivel
    }
}

void build_heap(int arr[], int n) {
    for (int i = n / 2 - 1; i >= 0; i--) {
        heapify_down(arr, n, i);
    }
}

void heapsort(int arr[], int n) {
    build_heap(arr, n);

    for (int end = n - 1; end > 0; end--) {
        // swap arr[0] <-> arr[end]  (saca el maximo al final)
        int tmp = arr[0];
        arr[0] = arr[end];
        arr[end] = tmp;

        // el heap ahora es [0, end); restaura la propiedad bajando la raiz
        heapify_down(arr, end, 0);
    }
}

int main() {
    const int n = 20;
    int arr[n] = {5, 13, 2, 25, 7, 17, 20, 8, 4, 30, 1, 9, 28, 11, 6, 22, 15, 3, 19, 12};

    cout << "Original: ";
    for (int k = 0; k < n; k++) cout << arr[k] << " ";
    cout << endl;

    heapsort(arr, n);

    cout << "Ordenado: ";
    for (int k = 0; k < n; k++) cout << arr[k] << " ";
    cout << endl;
    // Esperado: 1 2 3 4 5 6 7 8 9 11 12 13 15 17 19 20 22 25 28 30
    return 0;
}
