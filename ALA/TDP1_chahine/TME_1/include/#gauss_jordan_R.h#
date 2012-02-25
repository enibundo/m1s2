#ifndef GAUSS_JORDAN_R_H
#define GAUSS_JORDAN_R_H

/* Matrix row and column's numbers start at 1*/
typedef struct matrix_R
{
  int m;
  int n;
  float *mat;
} matrix_R;


/* Initializes to 0 a m*n matrix*/
int init_matrix_R (matrix_R *matrix, int m, int n );

/* Sets the float elem at matrix[i,j] */
int set_element ( matrix_R *matrix, int i, int j, float elem);

/* Returns the float at matrix[i,j] */
float get_element ( matrix_R *matrix, int i, int j);

/* Swaps the i_1'st row with the i_2'nd */
int swap_rows ( matrix_R *matrix, int i_1, int i_2);

/* Computes the rows op_type operation: [i_1 <- i_1 <op_type> lambda * i_2] */
int arith_rows (matrix_R *matrix, int i_1, int i_2, float lambda, char op_type);

/* Prints the matrix on given stream */
void fprint_matrix (FILE* stream, matrix_R *matrix);


/* Computes a Gauss-Jordan elimination */
int R_elimination (matrix_R *matrix);


#endif
