CC = gcc
CFLAGS = -g 
SRCDIR = src
OBJDIR = obj
OBJS = $(addprefix $(OBJDIR)/, main.o)

.PHONY:	all midi16 

all: midi16 

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS)-c $< -o $@

$(OBJS): $(OBJDIR)

midi16: $(OBJS)
	$(CC) $(CFLAGS)-lm $(OBJS) -o midi16

$(OBJDIR):
	-@mkdir $(OBJDIR)

clean:
	-@rm -rf $(OBJDIR) midi16 2> /dev/null
