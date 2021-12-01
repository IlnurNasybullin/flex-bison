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
#include <locale.h>

int yywrap();
int yylex();
int yyparse();

void yyerror(char const *s);

void yyerror (char const *s) {
	printf("%s\n", s);
}
%}
	
%%
select_list:
	select_list select |
	select |
	select_list select error {yyerror("Syntax error");} |
	select error {yyerror("Syntax error");}
select:
	select_part from_part where_part SQL_END {printf("correct SQL SELECT expression");}
select_part:
	SELECT select_opt field_list
field_list:
	'*' |
	field_names
field_names:
	field_names COMMA field_name |
	field_name
field_name:
	IDENTIFICATOR
from_part:
	FROM table_list
table_list:
	table_list COMMA table_name |
	table_name
table_name:
	IDENTIFICATOR
where_part:
	 |
	WHERE condition
select_opt:
	 |
	DISTINCT | 
	ALL
condition: 
	predicate |
	LB condition RB |
	condition condition_operator condition
predicate:
	NOT predicate |
	field_value '=' field_value |
	field_value '<''>' field_value |
	field_value '<''=' field_value |
	field_value '<' field_value |
	field_value '>''=' field_value |
	field_value '>' field_value
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
	calculated_expression |
	LB number_expression RB |
	number_expression number_operator number_expression
calculated_expression:
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