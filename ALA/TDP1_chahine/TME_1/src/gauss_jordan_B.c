#define _XOPEN_SOURCE 700

#include <stdlib.h>
#include <stdio.h>
#include <gauss_jordan_B.h>



int init_matrix_B (matrix_B *matrix, uint64_t m, uint64_t n)
{
  uint64_t i, nb_block = (uint64_t)(m * n / sizeof (uint64_t)) + 1;
  
  if (n <= 0 || m <= 0)
    {
      puts("ERROR.init_matrix_B: n = m = 0");
      return EXIT_FAILURE;
    }

  matrix->m = m;
  matrix->n = n;
  matrix->mat = malloc (nb_block * sizeof(uint64_t));
  
  for (i = 0; i < nb_block; i++)
    {
      matrix->mat[i] = 0;
    }
  return EXIT_SUCCESS;
}

 
uint64_t set_block (matrix_B *matrix, uint64_t i_block, uint64_t position, unsigned char elem)
{
  uint64_t res = matrix->mat[i_block];
  uint64_t elem64 = elem;
  switch (elem)
    {
    case 0:
      res &= elem64 << (sizeof(uint64_t) - position);
      break;
    case 1:
      res |= elem64 << (sizeof(uint64_t) - position);
      break;
    }
  return res;
}

int set_element ( matrix_B *matrix, uint64_t i, uint64_t j, unsigned char elem)
{ 
  uint64_t m = matrix->m;
  uint64_t n = matrix->n;

  if (elem > 1)
    {
      puts("[ ERROR ] gauss_jordan_B.set_element: elem is not a bit");
      return EXIT_FAILURE;
    }
  
  if ( i <= 0 || j <= 0 || i > m || j > n)
    {
      puts("[ ERROR ] gauss_jordan_uint64_t.set_element: index out of bounds");
      return EXIT_FAILURE;
    }
 
  /* TODO */
  matrix->mat[(i * n + j) / sizeof (uint64_t)] = 
  set_block (matrix, (i * n + j) / sizeof (uint64_t), (i * n + j) % sizeof (uint64_t), elem);
  
  return EXIT_SUCCESS;
}



char get_element ( matrix_B *matrix, uint64_t i, uint64_t j)
{
  uint64_t m = matrix->m;
  uint64_t n = matrix->n;
  
  if (i <= 0 || j <= 0 || i > m || j > n)
    {
      puts("[ ERROR ] gauss_jordan_uint64_t.get_element: index out of bounds");
      exit (EXIT_FAILURE);
    }
  return (char)0x01/*TODO*/;
}


int swap_rows ( matrix_B *matrix, uint64_t i_1, uint64_t i_2)
{
  uint64_t j;
  uint64_t buf;
  uint64_t m = matrix->m;
  uint64_t n = matrix->n;

  if (i_1 <= 0 || i_2 <= 0 || i_1 > m || i_2 > m)
    {
      puts("[ ERROR ] gauss_jordan_uint64_t.swap_rows: index out of bounds");
      return EXIT_FAILURE;
    }

  if (i_1 == i_2) return EXIT_SUCCESS;

  for (j = 0; j < n; j++)
    {

      buf = /*i_1*/;
      
      /*i_1=i_2;
	i_2=buf;
       */
    }

  return EXIT_SUCCESS;
}



int xor_rows (matrix_B *matrix, uint64_t i_1, uint64_t i_2)
{
  uint64_t j;
  uint64_t m = matrix->m;
  uint64_t n = matrix->n;
  
  if (lambda == 0)
    {
      return EXIT_SUCCESS;
    }


  if (i_1 <= 0 || i_2 <= 0 || i_1 > m || i_2 > m)
    {
      puts("[ ERROR ] gauss_jordan_uint64_t.arith_rows: index out of bounds");
      return EXIT_FAILURE;
    }
  
  for (j = 0; j < n; j++)
    {
      /*i_1 xor i_2*/;
    }
  
  return EXIT_SUCCESS;
}




/* TODO */ 
int B_elimination (matrix_B *matrix)
{
  int i, j, k;
  int m = matrix->m;
  int n = matrix->n;
  int min = (m < n) ? m : n;

  /* pivots[j]=i : le j-ème(colonne) pivot est à la ligne */
  int *pivots = malloc (min * sizeof(int));
  
  for (j = 0; j < min; j++)  pivots[j] = -1;
    
  for (j = 0; j < min; j++)
    {
      /* trouver pivot */
      for (i = j ,k = j; i < m && k < m; i++ , k++)
	{
       	  if (0 != matrix->mat[i * n + j])
	    {	      
	      pivots[j] = i;
	      break;
	    }
	  /* Swap to bottom */
	  swap_rows (matrix, i + 1, m);
	  i--;
	}
  
      /* Si pas de pivot de cette colonne */
      if (-1 == pivots[j]) continue;
      
      /* Réorganiser la matrice selon les pivots */
      swap_rows (matrix, j + 1, pivots[j] + 1);

      /* Nettoyage en bas */
      for (i = pivots[j]+1; i < min; i++)
	{
	  if (0 == matrix->mat[i * n + j]) continue;
	  arith_rows (matrix,
		      i + 1,
		      pivots[j] + 1,
		      matrix->mat[i * n + j] / matrix->mat[pivots[j] * n + j],
		      '-');
	}

      /* Nettoyage en haut */
       for (i = 0 ; i < pivots[j]; i++)
	{
	  if (0 != matrix->mat[i * n + j]) 
	    {
	  arith_rows (matrix,
		      i + 1,
		      pivots[j] + 1,
		      matrix->mat[i * n + j] / matrix->mat[pivots[j] * n + j],
		      '-');
	    }
	}
    }

  
  /* normalize */
  for (j = 0; j < min; j++) 
    { 
      if(-1 != pivots[j])
	{ 
	  arith_rows(matrix,
		     pivots[j] + 1,
		     pivots[j] + 1,
		     (1- matrix->mat[pivots[j] * n + j]) /matrix->mat[pivots[j] * n + j],
		     '+');
	}
    }
  
  return EXIT_SUCCESS;

}


void fprint_matrix (FILE* stream, matrix_B *matrix)
{
  uint64_t i;
  uint64_t j;
  uint64_t m = matrix->m;
  uint64_t n = matrix->n;
   
  for (i = 0; i < m; i++)
    {
      for (j = 0; j < n; j++)
	{
	  fprintf (stream, " %d ", get_element (matrix, i, j));
	  if (j == n - 1) fputs("\n", stream); 
	}
    }
}

