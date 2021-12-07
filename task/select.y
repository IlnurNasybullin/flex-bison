%token SELECT
%token FROM
%token COMMA
%token IDENTIFICATOR
%token WHERE
%token DISTINCT
%token ALL
%token LB
%token RB
%token NOT
%token AND
%token OR
%token NULL_W
%token DEFAULT
%token STRING
%token POSITIVE_NUMBER
%token SQL_END

%locations

%{
#include <stdio.h>

int yywrap();
int yylex();
int has_error = 0;

void yyerror(const char *str);
extern int yylineno;
extern int column;
extern char *lineptr;

void yyerror(const char *str) {
	fprintf(stderr, "error: %s in line %d, column %d\n", str, yylineno, column);
	fprintf(stderr, "%s", lineptr);
	for (int i = 0; i < column - 1; i++) {
		fprintf(stderr, "_");
	}
	fprintf(stderr, "^\n");
	has_error = 1;
}

void line_error(char const *s, int first_line) {
	printf("Error line: %d - %s\n", first_line, s);
	has_error = 1;
}

void printCorrect(int first_line) {
	if (has_error == 0) {
		printf("Line %d - correct SQL SELECT expression", first_line);
	}
	has_error = 0;
}
%}

%error-verbose

%start select_list

%expect 6
	
%%
select_list:
	select_list select |
	select
select:
	select_part from_part SQL_END {printCorrect($1);} |
	select_part from_part where_part SQL_END {printCorrect($1);}
select_part:
	SELECT field_list |
	SELECT select_opt field_list |
	error field_list {yyerrok;} |
	error select_opt field_list {yyerrok;}
field_list:
	'*' |
	field_names
field_names:
	field_name |
	field_names COMMA field_name |
	field_names error field_name {yyerrok; yyclearin;}
field_name:
	IDENTIFICATOR |
	error {yyerrok; yyclearin;}
from_part:
	FROM table_list
table_list:
	table_name |
	table_list COMMA table_name |
	table_list error table_name {yyerrok; yyclearin;}
table_name:
	IDENTIFICATOR |
	error {yyerrok; yyclearin;}
where_part:
	WHERE condition
select_opt:
	DISTINCT | 
	ALL
condition: 
	predicate |
	LB condition RB |
	condition condition_operator condition
predicate:
	NOT predicate |
	field_value comparison field_value
comparison:
	'=' |
	'<''>' |
	'<''=' |
	'<' |
	'>''=' |
	'>'
field_value:
	value
condition_operator:
	AND |
	OR
value:
	STRING |
	number_expression |
	NULL_W |
	DEFAULT
number_expression:
	computable_expression |
	LB number_expression RB |
	number_expression number_operator number_expression
computable_expression:
	number |
	IDENTIFICATOR
number_operator:
	'+' |
	'-' |
	'*' |
	'/'
number:
	negative_number | POSITIVE_NUMBER
negative_number:
	'-' POSITIVE_NUMBER
%%