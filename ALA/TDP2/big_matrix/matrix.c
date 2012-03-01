#include <stdio.h>
#include <stdlib.h>
#include "matrix.h"
// using uint64
#define SIZE_PER_BLOCK 64

matrix alloc_matrix(uint64 rows, uint64 columns) { 
  uint64 i;
  
  matrix ret = malloc (sizeof(struct _matrix));

  ret->rows = rows;
  ret->columns = columns;

  ret->elements = malloc (sizeof(uint64*)*rows);
  for (i = 0; i < columns; i++) {
    uint64 mod = columns % SIZE_PER_BLOCK;
    
    int padding = (mod == 0 ? 0 : 1);
    ret->elements[i]=(uint64*)(malloc(sizeof(uint64)*(columns / SIZE_PER_BLOCK + padding)));
  }
  return ret;
}

void initialise(matrix m) { 
  uint64 i, j;
  for (i=0; i<m->rows; i++) { 
    for (j=0; j<m->columns; j++) {
      m->elements[i][j]=0;
    }
  }
}

uint64 get_mask (uint64 position) {
  return ( ((uint64)1) << (63-position));
}

int get_element(matrix m, uint64 row, uint64 column) { 
  uint64 column_block = column / SIZE_PER_BLOCK;
  uint64 position_in_block = column % SIZE_PER_BLOCK;
  return (m->elements[row][column_block & get_mask(position_in_block)] == 0)? \
    0 : \
    1;
}

void swap_lines(matrix m, uint64 i, uint64 j) { 
  uint64 *temp = m->elements[i];
  m->elements[i]=m->elements[j];
  m->elements[j]=temp;
}

void print_matrix(matrix m) {
  uint64 i, j;
  for (i=0; i<m->rows; i++) { 
    for (j=0; j<m->columns/SIZE_PER_BLOCK; j++) { 
      printf (" %lld ", m->elements[i][j] & get_mask(j));
    }
    printf("\n");
  }
}

int set_element(matrix m, uint64 row, uint64 column, int val) { 
 
  uint64 column_block = column / SIZE_PER_BLOCK;
  uint64 position_in_block = column % SIZE_PER_BLOCK;
  uint64 mask = get_mask(position_in_block);
  uint64 ret = m->elements[row][column_block];

  printf("row : %lld column_block %lld mask : %lld\n", row, column_block, mask); 
  /*
    faire check des row/col/sizes
  */

  switch(val) {
  case 1:
    if (!(m->elements[row][column_block & mask]))
      m->elements[row][column_block] = ret | mask;
    break;
  case 0:
    if (m->elements[row][column_block & mask])
      m->elements[row][column_block] = ret ^ mask;
    break;
  default:
    fprintf(stderr, "ERROR");
    return 1;
  }
  return 0;
}

int main() { 
  matrix test = alloc_matrix(10, 10);
  initialise(test);
  set_element(test, (uint64)1, (uint64)1, 1);
  print_matrix(test);
  return 0;
}