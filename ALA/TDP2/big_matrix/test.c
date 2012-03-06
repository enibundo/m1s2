#include "matrix.h"
#include <stdlib.h>
#include <stdio.h>


int main() { 
  uint64 one = (uint64)1;
  int i;
  printf ("{");
  for (i=0; i<64; i++) { 
    printf ("%lld,\\ \n", one << (63-i));
  }
  printf("}");
  return 0;
}
