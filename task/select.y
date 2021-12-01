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
int has_error = 0;

void yyerror(char const *s);

void yyerror(char const *s) {
	printf("%s\n", s);
	has_error = 1;
}

void line_error(char const *s, int line_num) {
	printf("Error line: %d - %s\n", line_num, s);
	has_error = 1;
}
%}
	
%%
select_list:
	select_list select |
	select |
	select_list select error {line_error("Syntax error", $3);} |
	select error {line_error("Syntax error", $2);}
select:
	select_part from_part where_part SQL_END {
		if (has_error == 0) {
			printf("Line %d - correct SQL SELECT expression", $1);
		}
		has_error = 0;
	} |
	error from_part where_part SQL_END {line_error("expected select part of SQL expression", $1);} |
	select_part error where_part SQL_END {line_error("expected from part of SQL expression", $2);} |
	select_part from_part error SQL_END {line_error("incorrect where part of SQL expression", $3);} |
	select_part from_part where_part error {line_error("incorrect ending of SQL expression", $4);}
select_part:
	SELECT select_opt field_list |
	error SELECT select_opt field_list {line_error("incorrect SQL SELECT expression", $1);} |
	error select_opt field_list {line_error("expected SELECT keyword", $1);}
field_list:
	'*' |
	field_names
field_names:
	field_names COMMA field_name |
	field_name |
	field_names error field_name {line_error("incorrect delimeter between field names", $2);} |
	error {line_error("incorrect field name", $1);}
field_name:
	IDENTIFICATOR
from_part:
	FROM table_list |
	error table_list {line_error("expected FROM keyword", $1);}
	FROM error {line_error("expected table names' list", $2);}
table_list:
	table_list COMMA table_name |
	table_name |
	table_list error table_name {line_error("incorrect delimeter between table names", $2);} |
	error {line_error("incorrect table name", $1);}
table_name:
	IDENTIFICATOR
where_part:
	 |
	WHERE condition |
	error condition {line_error("expected WHERE keyword", $1);} |
	WHERE error {line_error("incorrect condition", $2);}
select_opt:
	 |
	DISTINCT | 
	ALL
condition: 
	predicate |
	LB condition RB |
	condition condition_operator condition |
	error condition RB {line_error("expected open bracket", $1);} |
	LB error RB {line_error("incorrect condition", $2);} |
	LB condition error {line_error("expected close bracket", $3);} |
	error condition_operator condition {line_error("incorrect condition", $1);}
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