%{
package main

import (
	"fmt"
	"text/scanner"
	"strings"
)


type Statement interface{}
type Clause interface{}
type Condition interface{}
type Symbol struct{
	//TokenType int
	Name string
}
type Literal struct{
	Type int //Token番号で数値か文字列か判定する
	Value string //数値でも文字列でもstringで値を持つ
}
type Num string
type Str string

var keywords = map[string]int{//文字列とトークン番号の紐付け用map
	//記号
	",":COMMA,
	";":SEMICOLON,
	"(":LPAREN,
	")":RPAREN,
	"*":ASTERISK,
	"\"":QUOTE,
	
	//比較演算子
	"==":EQ,
	"<>":NEQ,
	"<":LT,
	"<=":LE,
	">":GT,
	">=":GE,
	
	//Misc
	"IDENT":IDENT,

	//SQLのトークン
	"FROM":FROM,
	"JOIN":JOIN,
	"USING":USING,
	"WHERE":WHERE,
	"UNCONDIONAL":UNCONDIONAL,
	"ORDER":ORDER,
	"BY":BY,
	"ASC":ASC,
	"DESC":DESC,
	"GROUP":GROUP,
	"HAVING":HAVING,
	"DISTINCT":DISTINCT,
	"LIMIT":LIMIT,
	"SET":SET,
	"SELECT":SELECT,
	"UPDATE":UPDATE,
	"DELETE":DELETE,}

%}

%union{
	statement Statement
	clause Clause
	clause_list []Clause
	condition Condition
	symbol Symbol
	symbol_list []Symbol
	literal Literal
	comp_type int

	//専用の型に変更するかも
	num string
	str string
}

//nonterminal
%type<statement> statement select_statement update_statement delete_statement
%type<clause> join_clause where_clause select_clause group_by_clause having_clause order_by_clause limit_clause set_clause
%type<clause_list> join_clause_list set_clause_list
%type<condition> cond
%type<symbol_list> id_list
%type<literal> literal

//terminal
%token COMMA SEMICOLON LPAREN RPAREN ASTERISK QUOTE
%token<comp_type> EQ NEQ LT LE GT GE
%token<symbol> IDENT
%token<num> NUM
%token<str> STR
%token FROM JOIN USING WHERE UNCONDIONAL ORDER BY ASC DESC GROUP HAVING DISTINCT LIMIT SET SELECT UPDATE DELETE

%%
statement
	: select_statement SEMICOLON {fmt.Println("select statement is parsed")}
	| update_statement SEMICOLON {fmt.Println("update statement is parsed")}
	| delete_statement SEMICOLON {fmt.Println("delete statement is parsed")}

select_statement
	: FROM IDENT join_clause_list where_clause SELECT select_clause group_by_clause having_clause order_by_clause limit_clause
	{
		fmt.Println("a table",$2.Name,"is selected")
		$$ = new(Statement)
	}

join_clause_list
	: join_clause
	{
		l := make([]Clause,1)
		$$ = append(l,$1)
	}
	| join_clause_list COMMA join_clause
	{$$ = append($1,$3)}
	
join_clause
	: 
	{
		fmt.Println("not joined")
		$$ = new(Clause)
	}
	| JOIN IDENT USING LPAREN IDENT RPAREN
	{
		fmt.Println($2.Name,"joined using",$5.Name)
		$$ = new(Clause)
	}

where_clause
	: WHERE cond
	{$$ = new(Clause)}
	| WHERE UNCONDIONAL
	{
		fmt.Println("Unconditional")
		$$ = new(Clause)
	}

cond
	: IDENT comp literal
	{$$ = new(Condition)}

literal
	: NUM
	{
		fmt.Println("NUM:",$1)
		$$ = Literal{Type:NUM, Value:$1}
	}
	| STR
	{
		fmt.Println("STR:",$1)
		$$ = Literal{Type:STR, Value:$1}
	}

comp
	: EQ	{fmt.Println("==")}
	| NEQ	{fmt.Println("<>")}
	| LT	{fmt.Println("<")}
	| LE	{fmt.Println("<=")}
	| GT	{fmt.Println(">")}
	| GE	{fmt.Println(">=")}

select_clause
	: ASTERISK 
	{
		fmt.Println("asterisk!")
		$$ = new(Clause)
	}
	| id_list
	{
		$$ = new(Clause)
	}

id_list
	: IDENT
	{
		fmt.Println("IDENT:",$1.Name)
		l := make([]Symbol,0)
		$$ = append(l,$1)
	}
	| id_list COMMA IDENT
	{
		fmt.Println("IDENT:",$3.Name)
		$$ = append($1,$3)
	}

group_by_clause
	: {fmt.Println("not grouped")}
	| GROUP BY id_list
	{
		fmt.Println("grouping")
		$$ = new(Clause)
	}

having_clause
	: //保留
	{$$ = new(Clause)}

order_by_clause
	: {fmt.Println("not ordered")}
	| ORDER BY IDENT ASC
	{
		fmt.Println("ordered by",$3.Name)
		fmt.Println("asc")
	}
	| ORDER BY IDENT DESC
	{
		fmt.Println("ordered by",$3.Name)
		fmt.Println("desc")
	}

limit_clause
	: {fmt.Println("not limited")}
	| LIMIT NUM {fmt.Println("limited:",$2)}

update_statement
	: UPDATE IDENT where_clause order_by_clause limit_clause SET set_clause_list 
	{$$ = new(Statement)}

set_clause_list
	: set_clause
	{
		l := make([]Clause,0)
		$$ = append(l,$1)
	}
	| set_clause_list COMMA set_clause
	{
		$$ = append($1,$3)
	}

set_clause
	: IDENT EQ literal
	{$$ = new(Clause)}
	
delete_statement
	: DELETE FROM IDENT where_clause order_by_clause limit_clause
	{$$ = new(Statement)}
%%

type Lexer struct{
	scanner.Scanner
}

func (l *Lexer)Lex(lval *yySymType) int {
	token := int(l.Scan())
	literal := l.TokenText()
	if token == scanner.Int {
		token = NUM
	} else {
		if keyword,ok := keywords[literal];ok{
			token = keyword
		} else {
			token = IDENT
		}
		// TODO: STRに対する字句解析をする
	}
	lval.symbol = Symbol{Name: literal}
	lval.literal = Literal{Type:token, Value:literal}
	return token
}

func (l *Lexer)Error(e string){
	fmt.Println("Error:",e)
}

func main(){
	l := new(Lexer)
	l.Init(strings.NewReader(
`
FROM Todo JOIN Staff USING(staffId)
WHERE staffId = 1
GROUP BY deadline
SELECT COUNT(*),deadline
ORDER BY deadline ASC
LIMIT 3;
`))
	yyParse(l)
}
