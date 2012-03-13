/*********************************************************

matrix                   | lost padding
+------------------------+
|[ INTEGER 1 ] [ INTEGER | 2 ]
|[ INTEGER 2 ] [ INTEGER | 3 ]
|[ INTEGER 4 ] [ INTEGER | 5 ]
|    . . . . . .         |...
|                        |...
|                        |...
+------------------------+

*********************************************************/
typedef unsigned long long int uint64;

typedef struct _matrix { 
  
  int rows;
  int columns;
  
  uint64** elements;
} *matrix;
