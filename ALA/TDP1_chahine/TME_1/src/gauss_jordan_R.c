#define _XOPEN_SOURCE 700

#include <stdlib.h>
#include <stdio.h>
#include <gauss_jordan_R.h>



int init_matrix_R (matrix_R *matrix, int m, int n)
{
  int i, j;

  if (n <= 0 || m <= 0)
    {
      puts("ERROR.init_matrix_R: n = m = 0");
      return EXIT_FAILURE;
    }

  matrix->m = m;
  matrix->n = n;
  matrix->mat = malloc (m * n * sizeof (float));
  
  for (i = 0; i < m; i++)
    {
      for (j = 0; j < n; j++)
	{
	  matrix->mat[i * n + j] = 0;
	}
    }
  return EXIT_SUCCESS;
}

 
int set_element ( matrix_R *matrix, int i, int j, float elem)
{ 
  int m = matrix->m;
  int n = matrix->n;
  
  if ( i <= 0 || j <= 0 || i > m || j > n)
    {
      puts("[ ERROR ] gauss_jordan_R.set_element: index out of bounds");
      return EXIT_FAILURE;
    }
  matrix->mat[(i - 1) * n + j - 1] = elem;
  return EXIT_SUCCESS;
}



float get_element ( matrix_R *matrix, int i, int j)
{
  int m = matrix->m;
  int n = matrix->n;
  
  if (i <= 0 || j <= 0 || i > m || j > n)
    {
      puts("[ ERROR ] gauss_jordan_R.get_element: index out of bounds");
      exit (EXIT_FAILURE);
    }

  return matrix->mat[(i - 1) * n + j - 1];
}


int swap_rows ( matrix_R *matrix, int i_1, int i_2)
{
  int j;
  int buf;
  int m = matrix->m;
  int n = matrix->n;

  if (i_1 <= 0 || i_2 <= 0 || i_1 > m || i_2 > m)
    {
      puts("[ ERROR ] gauss_jordan_R.swap_rows: index out of bounds");
      return EXIT_FAILURE;
    }

  if (i_1 == i_2) return EXIT_SUCCESS;

  for (j = 0; j < n; j++)
    {
      buf = matrix->mat[(i_1 - 1) * n + j];
      matrix->mat[(i_1 - 1) * n + j] = matrix->mat[(i_2 - 1) * n + j];
      matrix->mat[(i_2 - 1) * n + j] = buf;
    }

  return EXIT_SUCCESS;
}



int arith_rows (matrix_R *matrix, int i_1, int i_2, float lambda, char op_type)
{
  int j;
  int m = matrix->m;
  int n = matrix->n;
  
  if (lambda == 0)
    {
      return EXIT_SUCCESS;
    }


  if (i_1 <= 0 || i_2 <= 0 || i_1 > m || i_2 > m)
    {
      puts("[ ERROR ] gauss_jordan_R.arith_rows: index out of bounds");
      return EXIT_FAILURE;
    }

  
  switch (op_type)
    {
    case '+':
      for (j = 0; j < n; j++)
	{
	  matrix->mat[(i_1 - 1) * n + j] += matrix->mat[(i_2 - 1) * n + j] * lambda;
	}
      break;

    case '-':
      for (j = 0; j < n; j++)
	{
	  matrix->mat[(i_1 - 1) * n + j] -= matrix->mat[(i_2 - 1) * n + j] * lambda;
	}
      break;
    }
  return EXIT_SUCCESS;
}



int R_elimination (matrix_R *matrix)
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


void fprint_matrix (FILE* stream, matrix_R *matrix)
{
  int i;
  int j;
  int m = matrix->m;
  int n = matrix->n;
   
  for (i = 0; i < m; i++)
    {
      for (j = 0; j < n; j++)
	{
	  fprintf (stream, " %8.2f ", matrix->mat[i * n + j]);
	  if (j == n - 1) fputs("\n", stream); 
	}
    }
}


