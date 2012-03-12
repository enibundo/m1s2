int B_elimination (matrix_B *matrix)
{
  int i = -1, j, k;
  int m = matrix->m;
  int n = matrix->n;
  int min = (m < n) ? m : n;

  /* pivots[j]=i : le j-ème(colonne) pivot est à la ligne */
    int *pivots = malloc (n * sizeof(int));
  
  /* init pivots */
  for (j = 0; j < n; j++)  pivots[j] = -1;

  /* pour chaque colonne */
  for (j = 0; j < n; j++)
    {
      
      if (j == 0 || pivots[j - 1] != -1) i++;
      
      /* trouver pivot */
      for (k = i;k < m; k++)
	{
       	  if (0 != get_element(matrix, i + 1, j + 1))
	    {	
	      pivots[j] = i;
	      break;
	    }
	  /* Swap to bottom */
	  swap_rows (matrix, i + 1, m);
	}
  
 
      /* Si pas de pivot de cette colonne */
      if (-1 == pivots[j]) continue;

      /* Réorganiser la matrice selon les pivots */
      swap_rows (matrix, i + 1, pivots[j] + 1);
      
  
     /* Nettoyage en bas */
      for (k = pivots[j] + 1; k < min; k++)
	{
	  if (0 == get_element(matrix, k + 1, j + 1)) continue;
	  xor_rows (matrix,
		      k + 1,
		    pivots[j] + 1);
		    
	}
 
      /* Nettoyage en haut */
       for (k = 0 ; k < pivots[j]; k++)
	{
	  if (0 != get_element(matrix, k + 1, j + 1)) 
	    {
	  xor_rows (matrix,
		      k + 1,
		    pivots[j] + 1);
	    }
	}
       
    }
  
  free(pivots);
  return EXIT_SUCCESS;

}
