CC=gcc
CFLAGS=-O2
SRCDIR=.
OBJDIR=bin
OBJS=$(addprefix $(OBJDIR)/, bitmap.o palette.o sprite.o main.o)

.PHONY:	all img16

all: img16

img16: $(OBJDIR) $(OBJS) 
	$(CC) $(CFLAGS) -lm $(OBJS) -o img16

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR):
	-@test -d $(OBJDIR) || mkdir $(OBJDIR)

clean:
	-@rm -rf $(OBJDIR) img16 2> /dev/null
