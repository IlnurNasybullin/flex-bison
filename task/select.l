%{
#include <stdio.h>
#include <string.h>
#include "select.tab.h"

extern int yylval;
static int next_column = 1;
int column = 1;

int yyparse();

#define HANDLE_COLUMN column = next_column; next_column += strlen(yytext)

char *lineptr = NULL;
size_t n = 0;
size_t consumed = 0;
size_t available = 0;	

size_t min(size_t a, size_t b);
int strcmp(const char* str1, const char* str2);

#define YY_INPUT(buf, result, max_size) {\
	if (available <= 0) {\
		consumed = 0;\
		available = getline(&lineptr, &n, yyin);\
		if (available < 0) {\
			if (ferror(yyin)) {\
				perror("read error:");\
			}\
			available = 0;\
		}\
	}\
	result = min(available, max_size);\
	strncpy(buf, lineptr + consumed, result);\
	consumed += result;\
	available -= result;\
}

%}

%option yylineno

SELECT_W				[Ss][Ee][Ll][Ee][Cc][Tt]
DISTINCT_W				[Dd][Ii][Ss][Tt][Ii][Nn][Cc][Tt]
ALL_W					[Aa][Ll][Ll]
FROM_W					[Ff][Rr][Oo][Mm]
WHERE_W					[Ww][Hh][Ee][Rr][Ee]
NOT_W					[Nn][Oo][Tt]
OR_W					[Oo][Rr]
AND_W					[Aa][Nn][Dd]
NULL_WW					[Nn][Uu][Ll][Ll]
DEFAULT_W				[Dd][Ee][Ff][Aa][Uu][Ll][Tt]
LB_W					\(
RB_W					\)
DELIMETER				[ \t\r\n]
COMMA_W					,
PUNCTUATION_MARK		\.|{COMMA_W}|\?|!|;|:
DIGIT					[0-9]
LETTER					[A-Za-z]
POSITIVE_NUMBER_W		{DIGIT}+(\.)?{DIGIT}*
SYMBOL					{DIGIT}|{LETTER}|{PUNCTUATION_MARK}|{DELIMETER}
STRING_W				\"({SYMBOL}|.)*\"
IDENTIFICATOR_W			({LETTER}|_)({LETTER}|_|{DIGIT})*
%%
{SELECT_W}				{HANDLE_COLUMN; return(SELECT);}
{DISTINCT_W}			{HANDLE_COLUMN; return(DISTINCT);}
{ALL_W}					{HANDLE_COLUMN; return(ALL);}
{FROM_W}				{HANDLE_COLUMN; return(FROM);}
{WHERE_W}				{HANDLE_COLUMN; return(WHERE);}
{NOT_W}					{HANDLE_COLUMN; return(NOT);}
{OR_W}					{HANDLE_COLUMN; return(OR);}
{AND_W}					{HANDLE_COLUMN; return(AND);}
{NULL_WW}				{HANDLE_COLUMN; return(NULL_W);}
{DEFAULT_W}				{HANDLE_COLUMN; return(DEFAULT);}
;						{HANDLE_COLUMN; return(SQL_END);}
{IDENTIFICATOR_W}		{HANDLE_COLUMN; return(IDENTIFICATOR);}
{POSITIVE_NUMBER_W}		{HANDLE_COLUMN; return(POSITIVE_NUMBER);}
{STRING_W}				{HANDLE_COLUMN; return(STRING);}
{LB_W}					{HANDLE_COLUMN; return(LB);}
{RB_W}					{HANDLE_COLUMN; return(RB);}
{COMMA_W}				{HANDLE_COLUMN; return(COMMA);}
[ \t\r]					{HANDLE_COLUMN; }
\n						{
							HANDLE_COLUMN;
							next_column = 1;
							printf("\n");
						}
.						{HANDLE_COLUMN; return(yytext[0]);}
%%
void main(int ac, char **av) {
	if (ac > 2 && strcmp(av[1], "-f") == 0 && (yyin=fopen(av[2], "r")) == NULL) {
		perror(av[2]);
		exit(1);
	}
	yyparse();
	free(lineptr);
	exit(0);
} 
int yywrap() {
	return(1);
}
size_t min(size_t a, size_t b) {
	return b < a ? b : a;
}