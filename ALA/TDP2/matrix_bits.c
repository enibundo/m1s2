// pour la structure de matrix
#include "matrix_bits.h"

#include <stdio.h>
#include <stdlib.h>

matrix alloc_matrix(uint64 rows, uint64 columns) {
  matrix ret = malloc(sizeof(struct _matrix));
  ret->rows = rows;
  ret->columns = columns;
  ret->elements = malloc(sizeof(uint64) * (rows*columns/SIZE_PER_BLOCK));
  return ret;
}

void free_matrix(matrix tofree){
  free(tofree);
}

uint64 get_mask (uint64 position) {
  return (1<<(63-position));
}

uint64 get_element(matrix m, uint64 row, uint64 column) {
  uint64 len = (row-1)*m->columns+column;
  uint64 block = len / SIZE_PER_BLOCK;
  uint64 pos = len % SIZE_PER_BLOCK;
  uint64 mask = get_mask (pos);

  uint64 ret= ((m->elements[block] & mask)!=0 ? ONE : ZERO);
  
  
  // DEBUG
  printf ("block %d; position %d; mask %d = %d\n", block, pos, mask, ret);

  return ret;


}

void print_matrix(matrix m) {
  uint64 i, j;
  
  for (i=0; i<m->rows; i++) {
    for (i=0; i<m->columns; i++) {
      printf ("%d ", get_element(m, i, j));
      fflush(stdout);
    }
    printf ("\n");
  }
}

/*
matrix construct_matrix (uint64 rows, uint64 columns, uint64 *elements) {
  uint64 i, j;
  matrix ret = alloc_matrix(rows, columns);
  for (i=0; i<rows*columns; i++) {
    ret->elements[i] = elements[i];
  }
  return ret;
}
*/



int main(){
  int i;

  matrix test = alloc_matrix(6, 4);
  
  // 111100001111000011110000
  // test->elements[0] = 15790320;
  
  test->elements[0] = 5;
  // print_matrix(test);
     for (i=0; i<64; i++) {
    printf ("%d - %ld\n", i, get_element(test, 1, i));
    }
     //printf ("%ld\n",get_element(test, 1, 20));  
  return 0;

}
