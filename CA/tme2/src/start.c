
#include <stdio.h>
#include <machine.h>

int main(int argc, char **argv){
   if(argv[1]==NULL){
      fputs("The machine need a program !\n", stderr);
      return 1;
   }
   
   printf("Initializing universal machine with %s\n", argv[1]);
   machine universelle= new_machine(argv[1]);
   printf("um initialized !\n");
   run(universelle);
   
}
