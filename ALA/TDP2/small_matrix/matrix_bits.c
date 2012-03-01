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
  return ( ((uint64)1) << (63-position));
}

uint64 get_block_of_cell(matrix m, uint64 row, uint64 column) {
  uint64 len = (row)*m->columns+column;
  uint64 block = len / SIZE_PER_BLOCK;
  return block;
}

uint64 get_position_of_cell(matrix m, uint64 row, uint64 column) {
  uint64 len = (row)*m->columns+column;
  uint64 pos = len % SIZE_PER_BLOCK;   
  return pos;
}

short get_element(matrix m, uint64 row, uint64 column) {

  uint64 block = get_block_of_cell(m, row, column);
  uint64 pos = get_position_of_cell(m, row, column);
  uint64 mask = get_mask (pos);
  
  short ret= ((m->elements[block] & mask)!=0 ? ONE : ZERO);  
  return ret;
}


// 
int set_element(matrix m, uint64 row, uint64 column, short value) {
  uint64 block = get_block_of_cell(m, row, column);
  uint64 pos = get_position_of_cell(m, row, column);
  uint64 mask = get_mask (pos);
  
  uint64 ret = m->elements[block];
  switch (value) { 
  case 1:
    if (!(ret & mask)) {
      m->elements[block] = ret | mask;
    }
    break;
  case 0:
    if (ret & mask) { 
      m->elements[block] = ret ^ mask;
    }
    break;
  default:
    fprintf(stderr, "ERROR in set_element, value should be 1 or 0");
    return 1;
  }
  return 0;
}

void initialise_matrix(matrix m){
  uint64 no_elements = m->rows * m->columns;
  int blocks = no_elements / SIZE_PER_BLOCK;
  uint64 i;
  for (i=0; i < blocks; i++) {
    m->elements[i]=0;
  }
}

void print_matrix(matrix m) {
  uint64 i, j;
  
  for (i=0; i<m->rows; i++) {
    for (j=0; j<m->columns; j++) {
      printf ("%d ", get_element(m, i, j));
      fflush(stdout);
    }
    printf ("\n");
  }
}

void swap_lines(matrix m, uint64 line1, uint64 line2) { 
  uint64 i;
  int tempo;
  short *bkup = malloc(sizeof(short)*m->columns);
  
  for (i = 0; i < m->columns; i++) {
    bkup[i] = get_element(m, line1, i);
  }
  
  for (i=0; i<m->columns; i++) { 
    tempo = get_element(m, line2, i);
    set_element(m, line1, i, tempo);
    set_element(m, line2, i, bkup[i]);
  }

}

void test_get_mask() { 
  uint64 i;
  printf("testing get_mask\n");
  for (i = 1; i<64; i++) { 
    printf("i=%lld -> get_mask = %lld\n", i, get_mask(i));
  }
  
}

void gaussjordan(matrix m) {
  int i, j;
  for (i=0; i<m->rows; i++) { 
    for (j=0; j<m->columns; j++) { 
    }
  }
}


/************ TEST FUNCTIONS ***********************/

void test_set_element_identity(matrix m) { 
  int i;
  
  for (i=0; i<4; i++) { 
    set_element(m, (uint64)i, (uint64)i, 1);
  }
  print_matrix(m);
  printf("===================\n");
}


void test_swap_lines(matrix m) {
  swap_lines(m, (uint64)1, (uint64)2);
  print_matrix(m);
  printf("====================\n");
}

/**************************************************/

int main(){

  matrix test = alloc_matrix(6, 4);

  initialise_matrix(test);
  test_set_element_identity(test);
  test_swap_lines(test);
  free_matrix(test);
  return 0;
}
