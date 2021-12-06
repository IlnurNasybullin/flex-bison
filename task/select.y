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
%{
#include <stdio.h>

int yywrap();
int yylex();
int yyparse();
int has_error = 0;

void yyerror(char const *s);

void yyerror(char const *s) {
	fprintf(stderr, "%s\n", s);
	has_error = 1;
}

void line_error(char const *s, int line_num) {
	printf("Error line: %d - %s\n", line_num, s);
	has_error = 1;
}

void printCorrect(int line_num) {
	if (has_error == 0) {
		printf("Line %d - correct SQL SELECT expression", line_num);
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
	error field_list {line_error("expected SELECT keyword", $1); yyerrok;} |
	error select_opt field_list {line_error("expected SELECT keyword", $1); yyerrok;}
field_list:
	'*' |
	field_names
field_names:
	field_name |
	field_names COMMA field_name |
	field_names error field_name {line_error("incorrect separator between field names", $2); yyerrok; yyclearin;}
field_name:
	IDENTIFICATOR |
	error {line_error("incorrect field name", $1); yyerrok; yyclearin;}
from_part:
	FROM table_list
table_list:
	table_name |
	table_list COMMA table_name |
	table_list error table_name {line_error("incorrect separator between table names", $2); yyerrok; yyclearin;}
table_name:
	IDENTIFICATOR |
	error {line_error("incorrect table name", $1); yyerrok; yyclearin;}
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