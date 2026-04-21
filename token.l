%{
#include "cfg.tab.h"
#include<string.h>
#include<stdlib.h>
%}

%%

"while"    { return WHILE; }
"do"       { return DO; }
"if"       { return IF; }
"else"     { return ELSE; }
"for"      { return FOR; }
"print"    { return PRINT; }
"break"    { return BREAK; }

">="       { return GE; }
"<="       { return LE; }
"=="       { return EQ; }
"!="       { return NE; }
"&&"       { return AND; }
"||"       { return OR; }

[0-9]+     { yylval.num = atoi(yytext); return NUMBER; }

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.id = strdup(yytext);
    return ID;
}

[ \t\r\n]  ;

.          { return yytext[0]; }

%%

int yywrap() { return 1; }