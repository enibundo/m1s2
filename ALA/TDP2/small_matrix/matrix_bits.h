#define ONE 1
#define ZERO 0

#define SIZE_PER_BLOCK 64

typedef unsigned long long int uint64;

typedef struct _matrix {
  uint64 rows;
  uint64 columns;
  uint64* elements;
} *matrix;
