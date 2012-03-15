/*********************************************************

matrix                   | lost padding
+------------------------+
|[ INTEGER 1 ] [ INTEGER | 2 ]
|[ INTEGER 2 ] [ INTEGER | 3 ]
|[ INTEGER 4 ] [ INTEGER | 5 ]
|    . . . . . .         |...
|                        |...
|                        |...
+------------------------+

*********************************************************/
typedef unsigned long long int uint64;

typedef struct _matrix { 
  
  int rows;
  int columns;
  
  uint64** elements;
} *matrix;

int get_number_of_blocks(int columns);
matrix alloc_matrix(int rows, int columns);
void initialise(matrix m);
uint64 get_mask(uint64 position);
int get_element(matrix m, uint64 row, uint64 column);
void swap_lines(matrix m, uint64 i, uint64 j);
void print_matrix(matrix m);
void set_element(matrix m, int row, int column, int val);
int first_bit_position(matrix m, int line);
void swap(uint64 *a, uint64 *b);
void sort(uint64 arr[], uint64 arr2[], int beg, int end);
int normalize(matrix m);
void xor_lines(matrix m, int line1, int line2);
int ligne_nulle(matrix m, int line);
void gaussjordan(matrix m);
matrix easy_construct(int rows, int columns, int *elements);
