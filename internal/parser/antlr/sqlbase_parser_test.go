package parser

import (
	"github.com/antlr4-go/antlr/v4"
	_ "github.com/stretchr/testify/assert"
	"testing"
)

type CustomListener struct {
	*BaseSqlBaseParserListener
}

func (s *CustomListener) EnterCreateNamespace(ctx *CreateNamespaceContext) {
	println(ctx.GetChildOfType(0, IdentifierContext{}).(*antlr.TerminalNodeImpl))
}

//func (l *CustomListener) VisitTerminal(node antlr.TerminalNode) {
//	println(node.GetText())
//}

func TestSuite(t *testing.T) {
	sql := "CREATE NAMESPACE test;"

	inpurStream := antlr.NewInputStream(sql)
	lexer := NewSqlBaseLexer(inpurStream)
	tokenStream := antlr.NewCommonTokenStream(lexer, antlr.TokenDefaultChannel)
	parser := NewSqlBaseParser(tokenStream)
	println("Test Test Test")
	antlr.ParseTreeWalkerDefault.Walk(&CustomListener{}, parser.CompoundOrSingleStatement())
	// assert.Equal(t, build, true, "Needs to be valid syntax")
}
