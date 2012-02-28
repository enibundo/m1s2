
#ifndef MACHINE_H
#define MACHINE_H

#include <stdint.h>

#define NB_REGISTRES 8
#define NB_TAB_INIT 0xFFFF

typedef uint32_t plateau;
typedef plateau* tableau;

typedef struct _mach{
   plateau r[NB_REGISTRES]; // registres
   tableau* collection;
   plateau nb_tab;
   plateau next_tab;
   plateau pc; //program counter
}machine_t;

typedef machine_t* machine;

#define OP(x) ( ((x)>>28) & 0xF )

#define bitsA(x) ( ((x)>>6) & 0x7)
#define bitsB(x) ( ((x)>>3) & 0x7)
#define bitsC(x) ( (x) & 0x7 )

#define speA(x) ( ((x)>>25) & 0x7)
#define word(x) (x&0x01FFFFFF)

extern machine new_machine(char *prog_init);
extern void run(machine m);

char* instructions[16];

#endif
