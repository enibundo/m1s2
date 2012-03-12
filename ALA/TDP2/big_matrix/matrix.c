#include <stdio.h>
#include <stdlib.h>
#include "matrix.h"
// using uint64
#define SIZE_PER_BLOCK 64

uint64 get_number_of_blocks(uint64 columns) { 
  uint64 mod = columns % SIZE_PER_BLOCK;
  int padding = (mod == 0 ? 0 : 1);
  return (columns / SIZE_PER_BLOCK + padding);
}

matrix alloc_matrix(uint64 rows, uint64 columns) { 
  
  uint64 i;  
  matrix ret = malloc (sizeof(struct _matrix));

  ret->rows = rows;
  ret->columns = columns;

  ret->elements = malloc (sizeof(uint64*)*rows);
  
  for (i = 0; i < columns; i++) {
    ret->elements[i]=(uint64*)(malloc(sizeof(uint64)*(get_number_of_blocks(columns))));
  }
  
  return ret;
}

void initialise(matrix m) { 
  uint64 i, j;
  for (i=0; i<m->rows; i++) { 
    for (j=0; j<get_number_of_blocks(m->columns); j++) {
      m->elements[i][j]=0;
    }
  }
}

uint64 get_mask (uint64 position) {
  return ( ((uint64)1) << (64-position));
}

int get_element(matrix m, uint64 row, uint64 column) { 
  
  uint64 column_block = column / SIZE_PER_BLOCK;
  uint64 position_in_block = column % SIZE_PER_BLOCK;
  
  int ret = ((!(m->elements[row][column_block] & get_mask(position_in_block)))?0:1);

  return ret;
  
}

void swap_lines(matrix m, uint64 i, uint64 j) { 
  uint64 *temp = m->elements[i];
  m->elements[i]=m->elements[j];
  m->elements[j]=temp;
}

void print_matrix(matrix m) {
  uint64 i, j;
  printf ("+");
  for (j=0; j<m->columns; j++) { 
    printf ("   ");
  }
  printf ("+\n");
     
  for (i=0; i<m->rows; i++) { 
    printf ("|");
    for (j=0; j<m->columns; j++) { 
      printf (" %d ", get_element(m, i, j), i, j);
    }
    printf ("|");
    printf("\n");
  }
  
 printf ("+");
  for (j=0; j<m->columns; j++) { 
    printf ("   ");
  }
  printf ("+\n");
 
}

void set_element(matrix m, uint64 row, uint64 column, int val) { 

  uint64 column_block = column / SIZE_PER_BLOCK;
  uint64 position_in_block = column % SIZE_PER_BLOCK;
  uint64 mask = get_mask(position_in_block);

  uint64 ret = m->elements[row][column_block];
  
  switch(val) {
  case 1:
    if (!(m->elements[row][column_block] & mask)) {
      m->elements[row][column_block] = ret | mask;
    }
    break;
  case 0:
    if (m->elements[row][column_block] & mask) {
      m->elements[row][column_block] = ret ^ mask;
    }
    break;
  }
}


uint64 first_bit_position(matrix m, uint64 line) { 
  uint64 i, j;
  uint64 position=0;
  for (i=0; i<get_number_of_blocks(m->columns); i++) { 
    if (! m->elements[line][i])
      position += SIZE_PER_BLOCK;
    else {
      for (j=0; j<SIZE_PER_BLOCK; j++) { 
	if (! get_element(m, line, i*SIZE_PER_BLOCK+j))
	  position +=1;
	else {
	  return position;
	}
      }
    }
  }
  return -1; // ligne nulle
}


// swaps 2 entiers
void swap(uint64 *a, uint64 *b){
  uint64 t=*a; *a=*b; *b=t;
}

// sorts first and second arr
void sort(uint64 arr[], uint64 arr2[], int beg, int end){
  if (end > beg + 1){
    int piv = arr[beg];
    int l = beg + 1;
    int r = end;
    
    while (l < r){
      if (arr[l] <= piv)
	l++;
      else {
	r--;
	swap(&arr[l], &arr[r]);
	swap(&arr2[l], &arr2[r]);	
      }
    }
    l--;
    swap(&arr[l], &arr[beg]);
    swap(&arr2[l], &arr2[beg]);
    
    sort(arr, arr2, beg, l);
    sort(arr, arr2, r, end);
  }
}


int normalize(matrix m){ 
  uint64 lines[m->rows];
  uint64 lines_pivots[m->rows];
  uint64 already_swaped[m->rows];
  
  uint64 i, L, R, beg[m->rows], end[m->rows], piv, piv_lines;
  
  for (i=0; i < m->rows; i++) { 
    lines_pivots[i] = first_bit_position(m, i);
    lines[i]=i;
    already_swaped[i]=-1;
  }
  
  sort(lines_pivots, lines, 0, m->rows);
  
  matrix ret = alloc_matrix(m->rows, m->columns);
 
  for (i=0; i<m->rows; i++) {
    ret->elements[i]=m->elements[lines[i]];
  }
  for (i=0; i<m->rows; i++) {
    m->elements[i]=ret->elements[i];
  }
  
  free(ret->elements);
  free(ret);

}

void xor_lines(matrix m, uint64 line1, uint64 line2){ 
  uint64 i;
  uint64 blocks = get_number_of_blocks(m->columns);
  for (i=0; i < blocks; i++) { 
    m->elements[line2][i] ^= m->elements[line1][i];
  }
}


int ligne_nulle(matrix m, uint64 line) { 
  // SHOULD i be int?
  int ret = 1, i; // nulle 

  
  for (i=0; i<get_number_of_blocks(m->columns); i++) { 
    if (m->elements[line][i]) return 0;
  }
  return 1;
}

  
void gaussjordan(matrix m) { 
  uint64 i, j, h;
  
  printf("before normalizing:\n"); print_matrix(m);

  normalize(m);

  printf("after normalizing:\n"); print_matrix(m);

  for (i=0; i<m->columns; i++) { 
    for (j=0; j<m->rows; j++) { 
      for (h=j+1; h<m->rows; h++) { 
	if (get_element(m, j, i) &&
	    get_element(m, h, i) &&
	    first_bit_position(m, j) <= first_bit_position(m, h) &&
	    h !=j ) {


	  printf ("h= %lld j=%lld\n", h, j);
	  printf("going to xor %lld and ->%lld\n", h, j);

	  xor_lines(m, h, j);

	  print_matrix(m);
	  

	  normalize(m);
	  printf("after normalization\n");	  print_matrix(m);
	}
      }
    }
  }
}

matrix easy_construct(uint64 rows, uint64 columns, int* elements){  
  uint64 i, j, k=0;
  matrix ret = alloc_matrix(rows, columns);
  initialise(ret);
  
  for (i=0; i<rows; i++) { 
    for (j=0; j<columns; j++) {
      if (elements[k]) set_element(ret, i, j, elements[k]);
      k++;
    }
  }
  return ret;
}


int main() { 
  int i;
  
  int bits[] = { 
    1, 0, 1, 0, 0, 1, 			\
    0, 0, 0, 1,					\
    0, 1, 1, 0,					\
    1, 1, 1, 1 };
  
  int bits2[] = {1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, \
		 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, \
		 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, \
		 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, \
		 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0};
  
  matrix test = easy_construct((uint64)5, (uint64)16,  bits2);
  
  print_matrix(test);
  //gaussjordan(test);  
  //normalize(test);
  printf("=================\n");
  print_matrix(test);
  return 0;
}
