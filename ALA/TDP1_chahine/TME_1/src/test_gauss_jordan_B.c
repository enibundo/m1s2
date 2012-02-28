#define _XOPEN_SOURCE 700

#include <stdlib.h>
#include <stdio.h>

#include <gauss_jordan_B.h>


void test_init_matrix_B (matrix_B *mat, uint64_t m, uint64_t n )
{
  fputs("[ TEST ] init_matrix_B ...\t\t", stderr);
  if (EXIT_FAILURE == init_matrix_B (mat, m, n)) 
    {
      fputs("[ FAIL ]\n", stderr);
      exit (EXIT_FAILURE);
    }
  fputs("[ DONE ]\n", stderr);
}


void test_set_element ( matrix_B * mat , uint64_t i, uint64_t j, unsigned char elem)
{
  fprintf(stderr,
	  "[ TEST ] set_element [%lld;%lld] = %d ...\t",
	  i, j, elem);

  if (EXIT_FAILURE == set_element ( mat, i, j, elem))
    {
      fputs("[ FAIL ]\n", stderr);
      exit (EXIT_FAILURE);
    }
  fputs("[ DONE ]\n", stderr);  
}


void test_get_element ( matrix_B *mat, uint64_t i, uint64_t j, unsigned char elem)
{
  unsigned char res;
  fprintf(stderr,
	  "[ TEST ] get_element [%lld;%lld] = %d ?...\t",
	  i, j, elem);

  res = get_element ( mat, i, j);
  if (elem != res)
    {
      fputs("[ FAIL ]\n", stderr);
      exit (EXIT_FAILURE);
    }
  fputs("[ DONE ]\n", stderr);
}


void test_swap_rows ( matrix_B *mat, uint64_t i_1, uint64_t i_2)
{
  fprintf(stderr,
	  "[ TEST ] swap_rows %lld and %lld ...\t",
	  i_1, i_2);

  if (EXIT_FAILURE == swap_rows (mat, i_1, i_2))
    {
      fputs("[ FAIL ]\n", stderr);
      exit (EXIT_FAILURE);
    }
  fputs("[ DONE ]\n", stderr);
}


void test_xor_rows (matrix_B *mat, uint64_t i_1, uint64_t i_2)
{
  fprintf(stderr,
	  "[ TEST ] arith_rows %lld <- %lld xor %lld ...\t",
	  i_1, i_1, i_2);

  if (EXIT_FAILURE == xor_rows (mat, i_1, i_2))
    {
      fputs("[ FAIL ]\n", stderr);
      exit (EXIT_FAILURE);
    }
  fputs("[ DONE ]\n", stderr);
}

void test_B_elimination (matrix_B *mat)
{
  fputs("[ TEST ] Gauss-Jordan elimination ...\t", stderr);
  if (EXIT_FAILURE == B_elimination (mat)) 
    {
      fputs("[ FAIL ]\n", stderr);
      exit (EXIT_FAILURE);
    }
  fputs("[ DONE ]\n", stderr);

}


int main (int args, char ** argv)
{
  
  matrix_B * mat = malloc (sizeof (matrix_B));
    
  test_init_matrix_B (mat, 3, 3);
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
  
  test_xor_rows (mat, 1, 2);
  fputs ("\n", stderr);
  fprint_matrix (stderr, mat);
  fputs ("\n", stderr);
  

  /*
  test_init_matrix_B (mat, 3, 4);
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


  test_B_elimination (mat);

  fputs ("\n", stderr);
  fprint_matrix (stderr, mat);
  fputs ("\n", stderr);
*/
  return EXIT_SUCCESS;
}