%{
package main

import (
	"fmt"
	"text/scanner"
	"strings"
)
/*
使いそうな終端文字たち
const(
	EOF
	WHITE_SPACE

	COMMA
	SEMICOLON
	LPAREN
	RPAREN
	ASTERISK

	IDENT
	NUM
	STRING

	FROM
	WHERE
	UNCONDIONAL
	ORDER
	GROUP
	BY

	SELECT
	UPDATE
	DELETE

	EQ
	NEQ
	LT
	LE
)
*/

type Statement interface{}
type Clause interface{}
type Token struct{
	TokenNum int
	Literal string
}
type Num int

var keywords = map[string]int{
	"ORDER":ORDER,
	"BY":BY,
	"ASC":ASC,
	"DESC":DESC}

%}

%union{
	clause Clause
	token Token
	num Num
}

//nonterminal
%type<clause> order_by_clause

//terminal
%token ORDER BY ASC DESC
%token<token> IDENT
%token<num> NUM

%%
order_by_clause
	: ORDER BY IDENT ASC
	{
		fmt.Println("ordered by",$3.Literal)
		fmt.Println("asc")
	}
	| ORDER BY IDENT DESC
	{
		fmt.Println("ordered by",$3.Literal)
		fmt.Println("desc")
	}
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
	}
	lval.token = Token{TokenNum: token, Literal: literal}
	return token
}

func (l *Lexer)Error(e string){
	fmt.Errorf("Error,%s",e)
}

func main(){
	l := new(Lexer)
	l.Init(strings.NewReader("ORDER BY aaa ASC"))
	yyParse(l)
}
