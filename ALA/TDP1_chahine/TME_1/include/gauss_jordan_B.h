#ifndef GAUSS_JORDAN_B_H
#define GAUSS_JORDAN_B_H

/* Matrix row and column's numbers start at 1*/

typedef unsigned long long int uint64_t;

typedef struct matrix_B
{
  uint64_t m;
  uint64_t n;
  uint64_t *mat;
} matrix_B;


/* Initializes to 0 a m*n matrix*/
int init_matrix_B (matrix_B *matrix, uint64_t m, uint64_t n ); // OK

/* Sets the bit elem at matrix[i,j] */
int set_element ( matrix_B *matrix, uint64_t i, uint64_t j, unsigned char elem);

/* Returns the bit at matrix[i,j] */
unsigned char get_element ( matrix_B *matrix, uint64_t i, uint64_t j);

/* Swaps the i_1'st row with the i_2'nd */
int swap_rows ( matrix_B *matrix, uint64_t i_1, uint64_t i_2);

/* Computes the rows XOR operation: [i_1 <- i_1 XOR  i_2] */
int xor_rows (matrix_B *matrix, uint64_t i_1, uint64_t i_2);

/* Pruint64_ts the matrix on given stream */
void fprint_matrix (FILE* stream, matrix_B *matrix);


/* Computes a Gauss-Jordan elimination */
int B_elimination (matrix_B *matrix);


#endif
