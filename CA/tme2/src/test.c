
#include <stdio.h>
#include <machine.h>

plateau reverse(plateau p){
   plateau buf=0x0;
   int i;
   printf("avant: %#X\n", p);
   for(i=0; i<4; i++){
      buf<<=8;
      buf|=(p&0x000000FF);
      p>>=8;
   }
   printf("après: %#X\n", buf);
   return buf;
}

int main(int argc, char **argv){
   
   reverse(0x12345678);
   return 0;
}
