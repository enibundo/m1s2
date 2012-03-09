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
    for (j=0; j<m->columns; j++) {
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

int normalize(matrix m){ 
  uint64 lines[m->rows];
  uint64 lines_pivots[m->rows];
  uint64 i, L, R, beg[m->rows], end[m->rows], piv, piv_lines;
  
  // initialize arrays
  for (i=0; i < m->rows; i++) { 
    lines_pivots[i] = first_bit_position(m, i);
    lines[i]=i;
  }
  
  for (i=0; i<m->rows; i++) { 
    printf (" %lld->%lld\n", lines[i], lines_pivots[i]);
  }
  printf("============+++++++++===========\n");
  beg[0]=0;
  end[0]=m->rows-1;
  while (i>=0) {
    L=beg[i];
    R=end[i]-1;
    if (L<R) { 
      piv = lines_pivots[i];
      piv_lines = lines[i];
      
      if (i==m->rows-1) goto done;
      
      while (L<R) { 
	while (lines_pivots[R]>=piv && L<R) R--;
	if (L<R) {
	  lines_pivots[L++]=lines_pivots[R];
	  lines[L++]=lines[R];
	}
	
	while (lines_pivots[L]<=piv && L<R) L++;
	
	if (L<R) {
	  lines_pivots[R--]=lines_pivots[L];
	  lines[R--]=lines[L];
	}
      }

      lines_pivots[L] = piv;
      lines[L]=piv_lines;

      beg[i+1]=L+1;
      end[i+1]=end[i];
      end[i++]=L;
    } else {
      i--;
    }
  }
 done:

  for (i=0; i<m->rows; i++) { 
    printf (" %lld->%lld\n", lines[i], lines_pivots[i]);
  }

}

void xorLines(matrix m, uint64 line1, uint64 line2){ 
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
  // TODO
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
    1, 0, 1, 0,					\
    0, 0, 0, 1,					\
    0, 1, 1, 0,					\
    1, 1, 1, 1 };
  
  matrix test = easy_construct((uint64)4, (uint64)4, bits);
  
  print_matrix(test);
  //gaussjordan(test);
  normalize(test);
  printf("=================\n");
  //printf("%lld\n", first_bit_position(test, 0));
  //print_matrix(test);
  return 0;
}
