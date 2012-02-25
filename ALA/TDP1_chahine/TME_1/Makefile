CC     = gcc 
CFLAGS = -Wall -Werror --std=c99 -pedantic -pedantic-errors

BINDIR := bin
INCDIR := include
SRCDIR := src
OBJDIR := obj



.PHONY: all clean

all: $(BINDIR)/test_gauss_jordan_R $(BINDIR)/test_gauss_jordan_B   


############################################
#Dirs

$(BINDIR):
	mkdir -p $(BINDIR)

$(OBJDIR):
	mkdir -p $(OBJDIR)


#############################################
# Objs


$(OBJDIR)/gauss_jordan_R.o : $(SRCDIR)/gauss_jordan_R.c $(INCDIR)/gauss_jordan_R.h | $(OBJDIR)
	$(CC) $(CFLAGS) -o $@ -c  $< -I$(INCDIR) 

$(OBJDIR)/test_gauss_jordan_R.o : $(SRCDIR)/test_gauss_jordan_R.c $(INCDIR)/gauss_jordan_R.h | $(OBJDIR)
	$(CC) $(CFLAGS) -o $@ -c  $< -I$(INCDIR) 


$(OBJDIR)/gauss_jordan_B.o : $(SRCDIR)/gauss_jordan_B.c $(INCDIR)/gauss_jordan_B.h | $(OBJDIR)
	$(CC) $(CFLAGS) -o $@ -c  $< -I$(INCDIR) 

$(OBJDIR)/test_gauss_jordan_B.o : $(SRCDIR)/test_gauss_jordan_B.c $(INCDIR)/gauss_jordan_B.h | $(OBJDIR)
	$(CC) $(CFLAGS) -o $@ -c  $< -I$(INCDIR) 


#############################################
# Execs

$(BINDIR)/test_gauss_jordan_R: $(OBJDIR)/test_gauss_jordan_R.o $(OBJDIR)/gauss_jordan_R.o | $(BINDIR)
	$(CC) $(CFLAGS) -o $@ $^


$(BINDIR)/test_gauss_jordan_B: $(OBJDIR)/test_gauss_jordan_B.o $(OBJDIR)/gauss_jordan_B.o | $(BINDIR)
	$(CC) $(CFLAGS) -o $@ $^

#############################################
# Cleans

clean:
	rm -rf $(OBJDIR) $(BINDIR)
