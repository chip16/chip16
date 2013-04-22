CC = gcc
CFLAGS = -g 
SRCDIR = src
OBJDIR = obj
OBJS = $(addprefix $(OBJDIR)/, bitmap.o palette.o sprite.o main.o)

.PHONY:	all img16

all: img16

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS)-c $< -o $@

$(OBJS): $(OBJDIR)

img16: $(OBJS)
	$(CC) $(CFLAGS)-lm $(OBJS) -o img16

$(OBJDIR):
	-@mkdir $(OBJDIR)

clean:
	-@rm -rf $(OBJDIR) img16 2> /dev/null
