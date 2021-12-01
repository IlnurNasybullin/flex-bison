%{
#include <stdio.h>
#include "select.tab.h"

int strcmp(const char* str1, const char* str2);
extern int yylval = 1;
%}

%option nodefault

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
{SELECT_W}				return(SELECT);
{DISTINCT_W}			return(DISTINCT);
{ALL_W}					return(ALL);
{FROM_W}				return(FROM);
{WHERE_W}				return(WHERE);
{NOT_W}					return(NOT);
{OR_W}					return(OR);
{AND_W}					return(AND);
{NULL_WW}				return(NULL_W);
{DEFAULT_W}				return(DEFAULT);
;						return(SQL_END);
{IDENTIFICATOR_W}		return(IDENTIFICATOR);
{POSITIVE_NUMBER_W}		return(POSITIVE_NUMBER);
{STRING_W}				return(STRING);
{LB_W}					return(LB);
{RB_W}					return(RB);
{COMMA_W}				return(COMMA);
[ \t\r]					;
\n						{
							yylval++;
							printf("\n");
						}
.						return(yytext[0]);
%%
void main(int ac, char **av) {
	if (ac > 2 && strcmp(av[1], "-f") == 0 && (yyin=fopen(av[2], "r")) == NULL) {
		perror(av[2]);
		exit(1);
	}
	yyparse();
	exit(0);
} 
int yywrap() {
	return(1);
}