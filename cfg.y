%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

int yylex(void);
void yyerror(const char *s);


/* উপরে global variable যোগ করুন */
int last_if_cond = 0;

typedef struct {
    char name[50];
    int value;
} symbol;

symbol symtab[100];
int symcount = 0;

int getval(char *name) {
    for(int i=0;i<symcount;i++)
        if(strcmp(symtab[i].name,name)==0)
            return symtab[i].value;
    return 0;
}

void setval(char *name,int val) {
    for(int i=0;i<symcount;i++) {
        if(strcmp(symtab[i].name,name)==0) {
            symtab[i].value = val;
            return;
        }
    }
    strcpy(symtab[symcount].name,name);
    symtab[symcount].value = val;
    symcount++;
}

int skip_stack[100];
int skip_top = 0;

void push_skip(int s)  { skip_stack[skip_top++] = s; }
int  pop_skip()        { return skip_stack[--skip_top]; }
int  cur_skip()        { return skip_top > 0 ? skip_stack[skip_top-1] : 0; }

%}

%union {
    int num;
    char *id;
}

%token <num> NUMBER
%token <id> ID

%token WHILE DO IF ELSE FOR PRINT BREAK
%token GE LE EQ NE AND OR

%type <num> EXP

%left OR
%left AND
%left EQ NE
%left '>' '<' GE LE
%left '+' '-'
%left '*' '/'
%right '!'

%%

program:
    stmts
;

stmts:
      stmts stmt
    | stmt
;

stmt:
      assign ';'
    | EXP ';'              { if(!cur_skip()) printf("Result: %d\n", $1); }
    | print_stmt ';'
    | if_stmt
    | while_stmt
    | do_while_stmt
    | for_stmt
    | BREAK ';'
;

assign:
    ID '=' EXP { if(!cur_skip()) setval($1,$3); }
;

print_stmt:
    PRINT '(' EXP ')' { if(!cur_skip()) printf("Output: %d\n",$3); }
;

if_stmt:
    IF '(' EXP ')'
        {
            last_if_cond = $3;
            push_skip(cur_skip() || !$3);
        }
    '{' stmts '}' 
        {
            pop_skip();   /* if block শেষে pop করো */
        }
    else_part
;

else_part:
      ELSE
        {
            push_skip(cur_skip() || last_if_cond);
        }
      '{' stmts '}'
        { pop_skip(); }
    | /* empty */
;

while_stmt:
    WHILE '(' EXP ')' '{' stmts '}'
    {
    }
;

do_while_stmt:
    DO '{' stmts '}' WHILE '(' EXP ')' ';'
    {
    }
;

for_stmt:
    FOR '(' assign ';' EXP ';' assign ')' '{' stmts '}'
    {
    }
;

EXP:
      EXP '+' EXP { $$ = $1 + $3; }
    | EXP '-' EXP { $$ = $1 - $3; }
    | EXP '*' EXP { $$ = $1 * $3; }
    | EXP '/' EXP { $$ = $1 / $3; }

    | EXP '>' EXP { $$ = $1 > $3; }
    | EXP '<' EXP { $$ = $1 < $3; }
    | EXP GE EXP  { $$ = $1 >= $3; }
    | EXP LE EXP  { $$ = $1 <= $3; }
    | EXP EQ EXP  { $$ = $1 == $3; }
    | EXP NE EXP  { $$ = $1 != $3; }

    | EXP AND EXP { $$ = $1 && $3; }
    | EXP OR EXP  { $$ = $1 || $3; }
    | '!' EXP     { $$ = !$2; }

    | NUMBER      { $$ = $1; }
    | ID          { $$ = getval($1); }

    | '(' EXP ')' { $$ = $2; }
    | '[' EXP ']' { $$ = $2; }
;

%%

int main() {
    printf("Enter Program:\n");
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    printf("Syntax Error!\n");
}
