#include <stdio.h>
#include <stdlib.h>
#include <math.h> /* for fabs(double) */
typedef struct matrice {
  int rows;
  int columns;
  double *elements;
} *Matrix;

Matrix alloc_matrix(int rows, int columns) {
  Matrix ret = malloc(sizeof(struct matrice));
  ret->rows = rows;
  ret->columns = columns;
  ret->elements = malloc(sizeof(double)*rows*columns);
  return ret;
}

/*
 * initialises to 0 all elements of a matrix
 */
void initialise_matrix(Matrix m) {
  int i;
  for (i=0; i < (m->rows * m->columns); i++){
    m->elements[i]=0;
    printf ("...setting matrix[i]=matrix[%d] = \t0\n", i); 
  }
}

double get_element(Matrix m, int r, int c) {
  if (m->rows < r || m->columns < c) {
    fprintf(stderr, "index error get_element");
    exit(1);
  } 
  return m->elements[(r-1)* m->columns + c -1];
}

int set_element(Matrix m, int r, int c, double val) {
  if (m->rows < r || m->columns < c) {
    fprintf(stderr, "index error set_element\n");
    fprintf(stderr, "trying to access %d %d\n", r, c);
    exit(1);
  }  
  m->elements[(r-1)*m->columns + c-1]=val;
  return 0;
}

/*
 * 'ligne1' = 'a' * 'ligne2' + 'b' dans la matrice 'm'
 */
int linear_app(Matrix m, int l1, int l2, double a, double b) {
  int i;
  for (i=0; i < m->columns; i++) {
    double l1_val = get_element(m, l1-1, i);
    double l2_val = get_element(m, l2-1, i);
    double new_val = a * l2_val + b;
    if (set_element(m, l1-1, i, new_val)) exit(1);
  }
  return 0;
}

void print_matrix(Matrix m) {
  int i;
  for (i=0; i < m->rows* m->columns; i++) {
    printf (" %.2f ", m->elements[i]);
    if (((i+1) % (m->columns)) == 0) 
      printf ("\n");
  }
}

void swap_lines(Matrix m, int l1, int l2) {
  int i;
  for (i=0; i< m->columns; i++) {
    double bkup = get_element(m, l1, i);
    set_element(m, l1, i, get_element(m, l2, i));
    set_element(m, l2, i, bkup);
  }
}

Matrix build_matrix(double rows, double columns, double *vals) {
  
  int i;
  Matrix ret = alloc_matrix(rows, columns);
  
  for (i = 0; i<rows*columns; i++) {
    ret->elements[i] = vals[i];
  }
  return ret;
}

void gauss_jordan(Matrix m) {
  int height = m->rows;
  int width = m->columns;
  
  int maxrow, c, i, i2, x;
  double eps = 0.000000001;
  double temp, mix, mi2i;  

  for (i=1; i < height; i++) {
    maxrow = i;
    
    /* find max pivot */
  
    for (i2=i+2; i2<=height; i2++){
      if (fabs(get_element(m, i2, i)) > fabs(get_element(m, maxrow, i))) {
	maxrow = i2;
      }
    }


    swap_lines(m, i, maxrow);
    
    if (fabs(get_element(m, i, i)) <= eps) {
      exit; // false
    }
    
    for (i2=i+2; i2<height; i2++) {
      printf ("i2 = %d i= %d\n", i2,  i); 
      c = get_element(m, i2, i) / get_element(m, i, i);
      printf ("- i= %d\n", i); 
      
      for (x=i; x<=width; x++) {
	temp = get_element(m, i2, x);
	set_element(m, i2, x, temp-c*get_element(m, i, x));
	
      }
    }
  }
  
  
  for (i=height; i>0; i--) {
    c = get_element(m, i, i);
    for (i2=1; i2<=i; i2++) {
      for (x=width; x<= i; x--) {

	temp = get_element(m, i2, x);
	mix = get_element(m, i, x);
	mi2i = get_element(m, i2, i);
	
	set_element(m, i, x, temp - mix*mix/c);
	
      }
 
      temp = get_element (m, i, i);
      set_element(m, i, i, temp/c);

    }
    for (x=height+1; x<width; x++) {
      temp = get_element(m, i, x);
      set_element(m, i, x, temp/c);
    }
  } 
}

int main(){
  double arrtest[] =  {
    1.,  2.2,   3.3, 0.4,\
    5.5, 6.6,   7.7, 0.0,\
    9.0, 10.12, 11.2, 42.42
  };
  Matrix test = build_matrix(3, 4, arrtest);
  print_matrix (test);
  printf("\n\n-------------\n\n");
  gauss_jordan(test);
  //swap_lines(test, 1, 3);
  print_matrix (test);

  return 0;
}
