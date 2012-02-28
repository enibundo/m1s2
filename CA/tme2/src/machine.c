#include <machine.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#define new_tableau(nb_plateau) malloc(sizeof(plateau)*(nb_plateau))

char* instructions[16]=
{ "Conditional Move",
  "Array Index",
  "Array Amendment",
  "Addition",
  "Multiplication",
  "Division",
  "Not-And",
  "Halt",
  "Allocation",
  "Abandonment",
  "Ouput",
  "Input",
  "Load Program",
  "Orthography",
  "Unknown instruction",
  "Unknown instruction"
};

void print_instr(plateau instr){
   printf("instr=%#X:\n", instr);
   if(OP(instr)<13){
      printf("OP=%d(%s), A=%d, B=%d, C=%d\n\n", 
	     OP(instr), 
	     instructions[OP(instr)], 
	     bitsA(instr), bitsB(instr), bitsC(instr));
   }
   else{
      printf("OP=%d(%s), A=%d, value=%d\n\n", 
	     OP(instr), 
	     instructions[OP(instr)], 
	     speA(instr), word(instr));
   }
 
}

plateau reverse(plateau p){
   plateau buf=0x0;
   int i;
   for(i=0; i<4; i++){
      buf<<=8; // en le faisant avant ce n'est pas fait à la dernière itération
      buf|=(p&0x000000FF);
      p>>=8;
   }
   return buf;
}


machine new_machine(char *prog_init){
   int i, parchemin, nb_plateau_parchemin;
   machine m;
   struct stat buf_stat;
   
   if((m= malloc(sizeof(machine_t)))==NULL){
      fputs("universal machine broken\n", stderr);
      exit(1);
   }
   
   puts("new machine created");
   memset(m->r, 0, sizeof(plateau)*NB_REGISTRES);
   puts("registers initialized");
   
   if( (m->collection=malloc(sizeof(tableau)*NB_TAB_INIT))==NULL){
      fputs("unable to initialize collection\n", stderr);
      exit(1);
   }
   
   
   memset(m->collection, (uintptr_t)NULL, sizeof(tableau)*NB_TAB_INIT);
   puts("collection initialized");
   m->nb_tab=NB_TAB_INIT;
   m->next_tab=1;
   m->pc=0;

   if(stat(prog_init, &buf_stat)==-1){
      perror("scroll stats");
      exit(1);
   }

   nb_plateau_parchemin=buf_stat.st_size/4; // buf_stat.st_size en bytes !

   if( (m->collection[0]= new_tableau(nb_plateau_parchemin+1))==NULL){
      fputs("unable to initialize first array\n", stderr);
      exit(1);
   }
   m->collection[0][0]=nb_plateau_parchemin;//on sauvegarde la taille du tableau dans la case -1
   m->collection[0]++;
   
   puts("first array initialized\n");

   memset(m->collection[0], 0, sizeof(plateau)*nb_plateau_parchemin);
   
   parchemin=open(prog_init, O_RDONLY);
   read(parchemin, m->collection[0], buf_stat.st_size);
   
   for ( i = 0; i < nb_plateau_parchemin; i++) 
      m->collection[0][i]=reverse(m->collection[0][i]);
   
   return m;
}

/*
  #0. Conditional Move.

  The register A receives the value in register B,
  unless the register C contains 0.
*/
void conditionnalMove(machine m, plateau instr){
   if(m->r[bitsC(instr)]!=0){
      m->r[bitsA(instr)]=m->r[bitsB(instr)];
   }
}

/*
  #1. Array Index.

  The register A receives the value stored at offset
  in register C in the array identified by B.
*/
void arrayIndex(machine m, plateau instr){
   m->r[bitsA(instr)]=m->collection[ m->r[bitsB(instr)] ][ m->r[bitsC(instr)] ];
}

/*
  #2. Array Amendment.

  The array identified by A is amended at the offset
  in register B to store the value in register C.
*/
void arrayAmendment(machine m, plateau instr){
   m->collection[ m->r[bitsA(instr)] ][ m->r[bitsB(instr)] ]=m->r[bitsC(instr)];
}

/*
  #3. Addition.

  The register A receives the value in register B plus 
  the value in register C, modulo 2^32.
*/
void add(machine m, plateau instr){
   m->r[bitsA(instr)] = m->r[bitsB(instr)] + m->r[bitsC(instr)];
}

/*
  #4. Multiplication.

  The register A receives the value in register B times
  the value in register C, modulo 2^32.
*/
void mult(machine m, plateau instr){
   m->r[bitsA(instr)] = m->r[bitsB(instr)] * m->r[bitsC(instr)];
}

/*
  #5. Division.

  The register A receives the value in register B
  divided by the value in register C, if any, where
  each quantity is treated treated as an unsigned 32
  bit number.
*/
void divi(machine m, plateau instr){
   m->r[bitsA(instr)] = m->r[bitsB(instr)] / m->r[bitsC(instr)];
}

/*
  #6. Not-And.

  Each bit in the register A receives the 1 bit if
  either register B or register C has a 0 bit in that
  position.  Otherwise the bit in register A receives
  the 0 bit.
*/
void nand(machine m, plateau instr){
   m->r[bitsA(instr)] = ~(m->r[bitsB(instr)] & m->r[bitsC(instr)]);
}

/*
  #7. Halt.

  The universal machine stops computation.
 */
void stop(machine m){
   uint64_t i;
   for(i=0; i<m->nb_tab; i++){
      if(m->collection[i]!=NULL){
	 free(&(m->collection[i][-1]));
      }
   }
   free(m->collection);
   free(m);
   exit(0);
}

void extend_memory(machine m){
   int size;
   tableau *new_col;
   size=m->nb_tab;
   m->nb_tab*=2;
   new_col=realloc(m->collection,sizeof(tableau)*m->nb_tab);
   if(new_col==NULL){
      fputs("alloc fail !\n",stderr);
      stop(m);
   }

   m->collection=new_col;

   memset(m->collection+size, 
	  (uintptr_t)NULL, 
	  sizeof(tableau)*size);
}

/*
  #8. Allocation.

  A new array is created with a capacity of platters
  commensurate to the value in the register C. This
  new array is initialized entirely with platters
  holding the value 0. A bit pattern not consisting of
  exclusively the 0 bit, and that identifies no other
  active allocated array, is placed in the B register.
*/		  
void alloc(machine m, plateau instr){
   plateau size;
   tableau new_t;
   while(m->collection[m->next_tab]!=NULL){
      m->next_tab++;
      
      if(m->next_tab==m->nb_tab){
	 extend_memory(m);
      }
      
   }

   size=m->r[bitsC(instr)];
   new_t=new_tableau(size+1);
   new_t[0]=size;
   new_t++;
   m->collection[m->next_tab]=new_t;
   
   memset(m->collection[m->next_tab], 0, 
	  sizeof(plateau)*size);

   m->r[bitsB(instr)]=m->next_tab;
}

/*
  #9. Abandonment.
  
  The array identified by the register C is abandoned.
  Future allocations may then reuse that identifier.
*/
void abandon(machine m, plateau instr){
   tableau t=m->collection[m->r[bitsC(instr)]];
   t--;// il faut aussi désallouer la case conteant la taille du tableau ^^
   free(t);
   m->next_tab=m->r[bitsC(instr)];
   m->collection[ m->r[bitsC(instr)] ] = NULL;
}

/*
  #10. Output.

  The value in the register C is displayed on the console
  immediately. Only values between and including 0 and 255
  are allowed.
*/
void output(machine m, plateau instr){
   putc(m->r[bitsC(instr)], stdout);
   fflush (stdout);
}

/*
  #11. Input.

  The universal machine waits for input on the console.
  When input arrives, the register C is loaded with the
  input, which must be between and including 0 and 255.
  If the end of input has been signaled, then the 
  register C is endowed with a uniform value pattern
  where every place is pregnant with the 1 bit.
  */
void input (machine m, plateau instr){
   m->r[bitsC(instr)]=getc(stdin);
   if(m->r[bitsC(instr)]==EOF)
      m->r[bitsC(instr)]=0xFFFFFFFF;
}

/*
  #12. Load Program.

  The array identified by the B register is duplicated
  and the duplicate shall replace the '0' array,
  regardless of size. The execution finger is placed
  to indicate the platter of this array that is
  described by the offset given in C, where the value
  0 denotes the first platter, 1 the second, et
  cetera.

  The '0' array shall be the most sublime choice for
  loading, and shall be handled with the utmost
  velocity.
*/
void load(machine m, plateau instr){
   int id=m->r[bitsB(instr)];
   tableau new_t;
   m->pc=m->r[bitsC(instr)];

   if(id==0)
      return;

   if(m->collection[id][-1]>m->collection[0][-1]){
      new_t=realloc(&(m->collection[0][-1]), 
		    sizeof(plateau)*(m->collection[id][-1]+1) );
      new_t[0]=m->collection[id][-1];
      new_t++;
      m->collection[0]=new_t;
   }
   
   memcpy(m->collection[0], m->collection[id], 
	  sizeof(plateau)*m->collection[id][-1]);

   m->collection[0][-1]=m->collection[id][-1];
   
   
}

/*
  #13. Orthography.

  The value indicated is loaded into the register A
  forthwith.
*/
void orthography(machine m, plateau instr){
   m->r[speA(instr)]=word(instr);
}

void run(machine m){
   plateau instr;
   while(1){
      instr=m->collection[0][m->pc];
//printf("PC[%d] : ", m->pc);
//print_instr(instr);
  
      m->pc++;
      
      switch(OP(instr)){
      case 0:
	 conditionnalMove(m, instr);
	 break;
      case 1:
	 arrayIndex(m, instr);
	 break;
      case 2:
	 arrayAmendment(m, instr);
	 break;
      case 3:
	 add(m, instr);
	 break;
      case 4:
	 mult(m, instr);
	 break;
      case 5:
	 divi(m, instr);
	 break;
      case 6:
	 nand(m, instr);
	 break;
      case 7:
	 stop(m);
	 break;
      case 8:
	 alloc(m, instr);
	 break;
      case 9:
	 abandon(m, instr);
	 break;
      case 10:
	 output(m, instr);
	 break;
      case 11:
	 input(m, instr);
	 break;
      case 12:
	 load(m, instr);
	 break;
      case 13:
	 orthography(m, instr);
	 break;
      default:
	 fputs("cpu panic: unknown instruction\n", stderr);
	 exit(1);
      }
      
   }
}
