#define _XOPEN_SOURCE 700

#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>

#include <gauss_jordan_R.h>


void test_init_matrix_R (matrix_R *mat, int m, int n )
{
  fputs("[ TEST ] init_matrix_R ...\t\t", stderr);
  if (EXIT_FAILURE == init_matrix_R (mat, m, n)) 
    {
      fputs("[ FAIL ]\n", stderr);
      exit (EXIT_FAILURE);
    }
  fputs("[ DONE ]\n", stderr);
}


void test_set_element ( matrix_R * mat , int i, int j, float elem)
{
  fprintf(stderr,
	  "[ TEST ] set_element [%d;%d] = %.2f ...\t",
	  i, j, elem);

  if (EXIT_FAILURE == set_element ( mat, i, j, elem))
    {
      fputs("[ FAIL ]\n", stderr);
      exit (EXIT_FAILURE);
    }
  fputs("[ DONE ]\n", stderr);  
}


void test_get_element ( matrix_R *mat, int i, int j, float elem)
{
  int res;
  fprintf(stderr,
	  "[ TEST ] get_element [%d;%d] = %.2f ?...\t",
	  i, j, elem);

  res = get_element ( mat, i, j);
  if (elem != res)
    {
      fputs("[ FAIL ]\n", stderr);
      exit (EXIT_FAILURE);
    }
  fputs("[ DONE ]\n", stderr);
}


void test_swap_rows ( matrix_R *mat, int i_1, int i_2)
{
  fprintf(stderr,
	  "[ TEST ] swap_rows %d and %d ...\t",
	  i_1, i_2);

  if (EXIT_FAILURE == swap_rows (mat, i_1, i_2))
    {
      fputs("[ FAIL ]\n", stderr);
      exit (EXIT_FAILURE);
    }
  fputs("[ DONE ]\n", stderr);
}


void test_arith_rows (matrix_R *mat, int i_1, int i_2, float lambda, char op_type)
{
  fprintf(stderr,
	  "[ TEST ] arith_rows %d <- %d %c %.2f * %d ...\t",
	  i_1, i_1, op_type, lambda, i_2);

  if (EXIT_FAILURE == arith_rows (mat, i_1, i_2, lambda, op_type))
    {
      fputs("[ FAIL ]\n", stderr);
      exit (EXIT_FAILURE);
    }
  fputs("[ DONE ]\n", stderr);
}

void test_R_elimination (matrix_R *mat)
{
  fputs("[ TEST ] Gauss-Jordan elimination ...\t", stderr);
  if (EXIT_FAILURE == R_elimination (mat)) 
    {
      fputs("[ FAIL ]\n", stderr);
      exit (EXIT_FAILURE);
    }
  fputs("[ DONE ]\n", stderr);

}


int main (int args, char ** argv)
{
  
  matrix_R * mat = malloc (sizeof (matrix_R));
  
  
  /*
  test_init_matrix_R (mat, 3, 3);
  fputs ("\n", stderr);
  fprint_matrix (stderr, mat);
  fputs ("\n", stderr);

  test_set_element ( mat, 1, 1, 1);  
  test_set_element ( mat, 1, 2, 2);
  test_set_element ( mat, 1, 3, 3);

  test_set_element ( mat, 2, 1, 4);
  test_set_element ( mat, 2, 2, 0);
  test_set_element ( mat, 2, 3, 6);

  test_set_element ( mat, 3, 1, 7);
  test_set_element ( mat, 3, 2, 8);
  test_set_element ( mat, 3, 3, 9);

  
  fputs ("\n", stderr);
  fprint_matrix (stderr, mat);
  fputs ("\n", stderr);
    
  test_swap_rows (mat, 2, 3);
  fputs ("\n", stderr);
  fprint_matrix (stderr, mat);
  fputs ("\n", stderr);
  
  test_arith_rows (mat, 1, 2, 1, '-');
  fputs ("\n", stderr);
  fprint_matrix (stderr, mat);
  fputs ("\n", stderr);
  */


  test_init_matrix_R (mat, 3, 4);
  fputs ("\n", stderr);
  fprint_matrix (stderr, mat);
  fputs ("\n", stderr);


  test_set_element ( mat, 1, 1, 1);  
  test_set_element ( mat, 1, 2, 3);
  test_set_element ( mat, 1, 3, 4);
  test_set_element ( mat, 1, 4, 5);

  test_set_element ( mat, 2, 1, 2);
  test_set_element ( mat, 2, 2, 6);
  test_set_element ( mat, 2, 3, 8);
  test_set_element ( mat, 2, 4, 10);

  test_set_element ( mat, 3, 1, 7);
  test_set_element ( mat, 3, 2, 9);
  test_set_element ( mat, 3, 3, 12);
  test_set_element ( mat, 3, 4, 42);


  fputs ("\n", stderr);
  fprint_matrix (stderr, mat);
  fputs ("\n", stderr);


  test_R_elimination (mat);

  fputs ("\n", stderr);
  fprint_matrix (stderr, mat);
  fputs ("\n", stderr);

  return EXIT_SUCCESS;
}
