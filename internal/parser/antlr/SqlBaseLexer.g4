/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * This file is an adaptation of Sparks grammar.
 */

lexer grammar SqlBaseLexer;

/* TODO: Fix rune code */
@header {

import (
	"sync/atomic"
	"unicode/utf8"
)

type LexerState struct {
	hasUnclosedBracketedComment bool
	complexTypeLevelCounter int32
}

func NewLexerState() *LexerState {
	return &LexerState{
		hasUnclosedBracketedComment: true,
	}
}

func (l *LexerState) markUnclosedComment() {
	l.hasUnclosedBracketedComment = true
}

func (l *LexerState) incComplexTypeLevelCounter() {
	atomic.AddInt32(&l.complexTypeLevelCounter, 1)
}

func (l *LexerState) decComplexTypeLevelCounter() {
	if (l.complexTypeLevelCounter > 0) {
		atomic.AddInt32(&l.complexTypeLevelCounter, -1)
	}
}

func (l *LexerState) isShiftRightOperator() bool {
	return l.complexTypeLevelCounter == 0
}

type MyLayoutInterpretor struct {
	antlr.ILexerATNSimulator
	state *LexerState
}

func NewMyLayoutLexer(input antlr.CharStream) *SqlBaseLexer {
	l := NewSqlBaseLexer(input)
	// Re-assign the interpreter.
	i := &MyLayoutInterpretor{ILexerATNSimulator: l.Interpreter, state: NewLexerState()}
	l.Interpreter = i
	return l
}

func markUnclosedComment(l *SqlBaseLexer) {
	l.Interpreter.(interface {markUnclosedComment()}).markUnclosedComment()
}

func incComplexTypeLevelCounter(l *SqlBaseLexer) {
	l.Interpreter.(interface {incComplexTypeLevelCounter()}).incComplexTypeLevelCounter()
}

func decComplexTypeLevelCounter(l *SqlBaseLexer) {
	l.Interpreter.(interface {decComplexTypeLevelCounter()}).decComplexTypeLevelCounter()
}

func isShiftRightOperator(l *SqlBaseLexer) bool {
	return l.Interpreter.(interface {isShiftRightOperator() bool}).isShiftRightOperator()
}

}

@members {

func (l *SqlBaseLexer) isValidDecimal() bool {
    nextChar := l.GetInputStream().GetText(1, 2)
    r, _ := utf8.DecodeRuneInString(nextChar)
    if (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9') || r == '_' {
        return false
    }
    return true
}

func (l *SqlBaseLexer) isHint() bool {
    nextChar :=  l.GetInputStream().GetText(1, 2)
    r, _ := utf8.DecodeRuneInString(nextChar)
    if r == '+' {
        return true
    }
    return false
}

}

SEMICOLON: ';';

LEFT_PAREN: '(';
RIGHT_PAREN: ')';
COMMA: ',';
DOT: '.';
LEFT_BRACKET: '[';
RIGHT_BRACKET: ']';
BANG: '!';

// NOTE: If you add a new token in the list below, you should update the list of keywords
// and reserved tag in `docs/sql-ref-ansi-compliance.md#sql-keywords`, and
// modify `ParserUtils.toExprAlias()` which assumes all keywords are between `ADD` and `ZONE`.

//============================
// Start of the keywords list
//============================
//--SPARK-KEYWORD-LIST-START
ADD: 'ADD';
AFTER: 'AFTER';
AGGREGATE: 'AGGREGATE';
ALL: 'ALL';
ALTER: 'ALTER';
ALWAYS: 'ALWAYS';
ANALYZE: 'ANALYZE';
AND: 'AND';
ANTI: 'ANTI';
ANY: 'ANY';
ANY_VALUE: 'ANY_VALUE';
ARCHIVE: 'ARCHIVE';
ARRAY: 'ARRAY' {incComplexTypeLevelCounter(l);};
AS: 'AS';
ASC: 'ASC';
AT: 'AT';
AUTHORIZATION: 'AUTHORIZATION';
BEGIN: 'BEGIN';
BETWEEN: 'BETWEEN';
BIGINT: 'BIGINT';
BINARY: 'BINARY';
BINDING: 'BINDING';
BOOLEAN: 'BOOLEAN';
BOTH: 'BOTH';
BUCKET: 'BUCKET';
BUCKETS: 'BUCKETS';
BY: 'BY';
BYTE: 'BYTE';
CACHE: 'CACHE';
CALL: 'CALL';
CALLED: 'CALLED';
CASCADE: 'CASCADE';
CASE: 'CASE';
CAST: 'CAST';
CATALOG: 'CATALOG';
CATALOGS: 'CATALOGS';
CHANGE: 'CHANGE';
CHAR: 'CHAR';
CHARACTER: 'CHARACTER';
CHECK: 'CHECK';
CLEAR: 'CLEAR';
CLUSTER: 'CLUSTER';
CLUSTERED: 'CLUSTERED';
CODEGEN: 'CODEGEN';
COLLATE: 'COLLATE';
COLLATION: 'COLLATION';
COLLECTION: 'COLLECTION';
COLUMN: 'COLUMN';
COLUMNS: 'COLUMNS';
COMMENT: 'COMMENT';
COMMIT: 'COMMIT';
COMPACT: 'COMPACT';
COMPACTIONS: 'COMPACTIONS';
COMPENSATION: 'COMPENSATION';
COMPUTE: 'COMPUTE';
CONCATENATE: 'CONCATENATE';
CONSTRAINT: 'CONSTRAINT';
CONTAINS: 'CONTAINS';
COST: 'COST';
CREATE: 'CREATE';
CROSS: 'CROSS';
CUBE: 'CUBE';
CURRENT: 'CURRENT';
CURRENT_DATE: 'CURRENT_DATE';
CURRENT_TIME: 'CURRENT_TIME';
CURRENT_TIMESTAMP: 'CURRENT_TIMESTAMP';
CURRENT_USER: 'CURRENT_USER';
DAY: 'DAY';
DAYS: 'DAYS';
DAYOFYEAR: 'DAYOFYEAR';
DATA: 'DATA';
DATE: 'DATE';
DATABASE: 'DATABASE';
DATABASES: 'DATABASES';
DATEADD: 'DATEADD';
DATE_ADD: 'DATE_ADD';
DATEDIFF: 'DATEDIFF';
DATE_DIFF: 'DATE_DIFF';
DBPROPERTIES: 'DBPROPERTIES';
DEC: 'DEC';
DECIMAL: 'DECIMAL';
DECLARE: 'DECLARE';
DEFAULT: 'DEFAULT';
DEFINED: 'DEFINED';
DEFINER: 'DEFINER';
DELETE: 'DELETE';
DELIMITED: 'DELIMITED';
DESC: 'DESC';
DESCRIBE: 'DESCRIBE';
DETERMINISTIC: 'DETERMINISTIC';
DFS: 'DFS';
DIRECTORIES: 'DIRECTORIES';
DIRECTORY: 'DIRECTORY';
DISTINCT: 'DISTINCT';
DISTRIBUTE: 'DISTRIBUTE';
DIV: 'DIV';
DO: 'DO';
DOUBLE: 'DOUBLE';
DROP: 'DROP';
ELSE: 'ELSE';
END: 'END';
ESCAPE: 'ESCAPE';
ESCAPED: 'ESCAPED';
EVOLUTION: 'EVOLUTION';
EXCEPT: 'EXCEPT';
EXCHANGE: 'EXCHANGE';
EXCLUDE: 'EXCLUDE';
EXISTS: 'EXISTS';
EXPLAIN: 'EXPLAIN';
EXPORT: 'EXPORT';
EXTEND: 'EXTEND';
EXTENDED: 'EXTENDED';
EXTERNAL: 'EXTERNAL';
EXTRACT: 'EXTRACT';
FALSE: 'FALSE';
FETCH: 'FETCH';
FIELDS: 'FIELDS';
FILTER: 'FILTER';
FILEFORMAT: 'FILEFORMAT';
FIRST: 'FIRST';
FLOAT: 'FLOAT';
FOLLOWING: 'FOLLOWING';
FOR: 'FOR';
FOREIGN: 'FOREIGN';
FORMAT: 'FORMAT';
FORMATTED: 'FORMATTED';
FROM: 'FROM';
FULL: 'FULL';
FUNCTION: 'FUNCTION';
FUNCTIONS: 'FUNCTIONS';
GENERATED: 'GENERATED';
GLOBAL: 'GLOBAL';
GRANT: 'GRANT';
GROUP: 'GROUP';
GROUPING: 'GROUPING';
HAVING: 'HAVING';
BINARY_HEX: 'X';
HOUR: 'HOUR';
HOURS: 'HOURS';
IDENTIFIER_KW: 'IDENTIFIER';
IDENTITY: 'IDENTITY';
IF: 'IF';
IGNORE: 'IGNORE';
IMMEDIATE: 'IMMEDIATE';
IMPORT: 'IMPORT';
IN: 'IN';
INCLUDE: 'INCLUDE';
INCREMENT: 'INCREMENT';
INDEX: 'INDEX';
INDEXES: 'INDEXES';
INNER: 'INNER';
INPATH: 'INPATH';
INPUT: 'INPUT';
INPUTFORMAT: 'INPUTFORMAT';
INSERT: 'INSERT';
INTERSECT: 'INTERSECT';
INTERVAL: 'INTERVAL';
INT: 'INT';
INTEGER: 'INTEGER';
INTO: 'INTO';
INVOKER: 'INVOKER';
IS: 'IS';
ITEMS: 'ITEMS';
ITERATE: 'ITERATE';
JOIN: 'JOIN';
KEYS: 'KEYS';
LANGUAGE: 'LANGUAGE';
LAST: 'LAST';
LATERAL: 'LATERAL';
LAZY: 'LAZY';
LEADING: 'LEADING';
LEAVE: 'LEAVE';
LEFT: 'LEFT';
LIKE: 'LIKE';
ILIKE: 'ILIKE';
LIMIT: 'LIMIT';
LINES: 'LINES';
LIST: 'LIST';
LOAD: 'LOAD';
LOCAL: 'LOCAL';
LOCATION: 'LOCATION';
LOCK: 'LOCK';
LOCKS: 'LOCKS';
LOGICAL: 'LOGICAL';
LONG: 'LONG';
LOOP: 'LOOP';
MACRO: 'MACRO';
MAP: 'MAP' {incComplexTypeLevelCounter(l);};
MATCHED: 'MATCHED';
MERGE: 'MERGE';
MICROSECOND: 'MICROSECOND';
MICROSECONDS: 'MICROSECONDS';
MILLISECOND: 'MILLISECOND';
MILLISECONDS: 'MILLISECONDS';
MINUTE: 'MINUTE';
MINUTES: 'MINUTES';
MODIFIES: 'MODIFIES';
MONTH: 'MONTH';
MONTHS: 'MONTHS';
MSCK: 'MSCK';
NAME: 'NAME';
NAMESPACE: 'NAMESPACE';
NAMESPACES: 'NAMESPACES';
NANOSECOND: 'NANOSECOND';
NANOSECONDS: 'NANOSECONDS';
NATURAL: 'NATURAL';
NO: 'NO';
NONE: 'NONE';
NOT: 'NOT';
NULL: 'NULL';
NULLS: 'NULLS';
NUMERIC: 'NUMERIC';
OF: 'OF';
OFFSET: 'OFFSET';
ON: 'ON';
ONLY: 'ONLY';
OPTION: 'OPTION';
OPTIONS: 'OPTIONS';
OR: 'OR';
ORDER: 'ORDER';
OUT: 'OUT';
OUTER: 'OUTER';
OUTPUTFORMAT: 'OUTPUTFORMAT';
OVER: 'OVER';
OVERLAPS: 'OVERLAPS';
OVERLAY: 'OVERLAY';
OVERWRITE: 'OVERWRITE';
PARTITION: 'PARTITION';
PARTITIONED: 'PARTITIONED';
PARTITIONS: 'PARTITIONS';
PERCENTLIT: 'PERCENT';
PIVOT: 'PIVOT';
PLACING: 'PLACING';
POSITION: 'POSITION';
PRECEDING: 'PRECEDING';
PRIMARY: 'PRIMARY';
PRINCIPALS: 'PRINCIPALS';
PROPERTIES: 'PROPERTIES';
PURGE: 'PURGE';
QUARTER: 'QUARTER';
QUERY: 'QUERY';
RANGE: 'RANGE';
READS: 'READS';
REAL: 'REAL';
RECORDREADER: 'RECORDREADER';
RECORDWRITER: 'RECORDWRITER';
RECOVER: 'RECOVER';
REDUCE: 'REDUCE';
REFERENCES: 'REFERENCES';
REFRESH: 'REFRESH';
RENAME: 'RENAME';
REPAIR: 'REPAIR';
REPEAT: 'REPEAT';
REPEATABLE: 'REPEATABLE';
REPLACE: 'REPLACE';
RESET: 'RESET';
RESPECT: 'RESPECT';
RESTRICT: 'RESTRICT';
RETURN: 'RETURN';
RETURNS: 'RETURNS';
REVOKE: 'REVOKE';
RIGHT: 'RIGHT';
RLIKE: 'RLIKE' | 'REGEXP';
ROLE: 'ROLE';
ROLES: 'ROLES';
ROLLBACK: 'ROLLBACK';
ROLLUP: 'ROLLUP';
ROW: 'ROW';
ROWS: 'ROWS';
SECOND: 'SECOND';
SECONDS: 'SECONDS';
SCHEMA: 'SCHEMA';
SCHEMAS: 'SCHEMAS';
SECURITY: 'SECURITY';
SELECT: 'SELECT';
SEMI: 'SEMI';
SEPARATED: 'SEPARATED';
SERDE: 'SERDE';
SERDEPROPERTIES: 'SERDEPROPERTIES';
SESSION_USER: 'SESSION_USER';
SET: 'SET';
SETMINUS: 'MINUS';
SETS: 'SETS';
SHORT: 'SHORT';
SHOW: 'SHOW';
SINGLE: 'SINGLE';
SKEWED: 'SKEWED';
SMALLINT: 'SMALLINT';
SOME: 'SOME';
SORT: 'SORT';
SORTED: 'SORTED';
SOURCE: 'SOURCE';
SPECIFIC: 'SPECIFIC';
SQL: 'SQL';
START: 'START';
STATISTICS: 'STATISTICS';
STORED: 'STORED';
STRATIFY: 'STRATIFY';
STRING: 'STRING';
STRUCT: 'STRUCT' {incComplexTypeLevelCounter(l);};
SUBSTR: 'SUBSTR';
SUBSTRING: 'SUBSTRING';
SYNC: 'SYNC';
SYSTEM_TIME: 'SYSTEM_TIME';
SYSTEM_VERSION: 'SYSTEM_VERSION';
TABLE: 'TABLE';
TABLES: 'TABLES';
TABLESAMPLE: 'TABLESAMPLE';
TARGET: 'TARGET';
TBLPROPERTIES: 'TBLPROPERTIES';
TEMPORARY: 'TEMPORARY' | 'TEMP';
TERMINATED: 'TERMINATED';
THEN: 'THEN';
TIME: 'TIME';
TIMEDIFF: 'TIMEDIFF';
TIMESTAMP: 'TIMESTAMP';
TIMESTAMP_LTZ: 'TIMESTAMP_LTZ';
TIMESTAMP_NTZ: 'TIMESTAMP_NTZ';
TIMESTAMPADD: 'TIMESTAMPADD';
TIMESTAMPDIFF: 'TIMESTAMPDIFF';
TINYINT: 'TINYINT';
TO: 'TO';
EXECUTE: 'EXECUTE';
TOUCH: 'TOUCH';
TRAILING: 'TRAILING';
TRANSACTION: 'TRANSACTION';
TRANSACTIONS: 'TRANSACTIONS';
TRANSFORM: 'TRANSFORM';
TRIM: 'TRIM';
TRUE: 'TRUE';
TRUNCATE: 'TRUNCATE';
TRY_CAST: 'TRY_CAST';
TYPE: 'TYPE';
UNARCHIVE: 'UNARCHIVE';
UNBOUNDED: 'UNBOUNDED';
UNCACHE: 'UNCACHE';
UNION: 'UNION';
UNIQUE: 'UNIQUE';
UNKNOWN: 'UNKNOWN';
UNLOCK: 'UNLOCK';
UNPIVOT: 'UNPIVOT';
UNSET: 'UNSET';
UNTIL: 'UNTIL';
UPDATE: 'UPDATE';
USE: 'USE';
USER: 'USER';
USING: 'USING';
VALUES: 'VALUES';
VARCHAR: 'VARCHAR';
VAR: 'VAR';
VARIABLE: 'VARIABLE';
VARIANT: 'VARIANT';
VERSION: 'VERSION';
VIEW: 'VIEW';
VIEWS: 'VIEWS';
VOID: 'VOID';
WEEK: 'WEEK';
WEEKS: 'WEEKS';
WHEN: 'WHEN';
WHERE: 'WHERE';
WHILE: 'WHILE';
WINDOW: 'WINDOW';
WITH: 'WITH';
WITHIN: 'WITHIN';
YEAR: 'YEAR';
YEARS: 'YEARS';
ZONE: 'ZONE';
//--SPARK-KEYWORD-LIST-END
//============================
// End of the keywords list
//============================

EQ  : '=' | '==';
NSEQ: '<=>';
NEQ : '<>';
NEQJ: '!=';
LT  : '<';
LTE : '<=' | '!>';
GT  : '>' {decComplexTypeLevelCounter(l);};
GTE : '>=' | '!<';
SHIFT_LEFT: '<<';
SHIFT_RIGHT: '>>' {isShiftRightOperator(p)}?;
SHIFT_RIGHT_UNSIGNED: '>>>' {isShiftRightOperator(p)}?;

PLUS: '+';
MINUS: '-';
ASTERISK: '*';
SLASH: '/';
PERCENT: '%';
TILDE: '~';
AMPERSAND: '&';
PIPE: '|';
CONCAT_PIPE: '||';
OPERATOR_PIPE: '|>';
HAT: '^';
COLON: ':';
DOUBLE_COLON: '::';
ARROW: '->';
FAT_ARROW : '=>';
HENT_START: '/*+';
HENT_END: '*/';
QUESTION: '?';

STRING_LITERAL
    : '\'' ( ~('\''|'\\') | ('\\' .) )* '\''
    | 'R\'' (~'\'')* '\''
    | 'R"'(~'"')* '"'
    ;

DOUBLEQUOTED_STRING
    :'"' ( ~('"'|'\\') | ('\\' .) )* '"'
    ;

// NOTE: If you move a numeric literal, you should modify `ParserUtils.toExprAlias()`
// which assumes all numeric literals are between `BIGINT_LITERAL` and `BIGDECIMAL_LITERAL`.

BIGINT_LITERAL
    : DIGIT+ 'L'
    ;

SMALLINT_LITERAL
    : DIGIT+ 'S'
    ;

TINYINT_LITERAL
    : DIGIT+ 'Y'
    ;

INTEGER_VALUE
    : DIGIT+
    ;

EXPONENT_VALUE
    : DIGIT+ EXPONENT
    | DECIMAL_DIGITS EXPONENT {p.isValidDecimal()}?
    ;

DECIMAL_VALUE
    : DECIMAL_DIGITS {p.isValidDecimal()}?
    ;

FLOAT_LITERAL
    : DIGIT+ EXPONENT? 'F'
    | DECIMAL_DIGITS EXPONENT? 'F' {p.isValidDecimal()}?
    ;

DOUBLE_LITERAL
    : DIGIT+ EXPONENT? 'D'
    | DECIMAL_DIGITS EXPONENT? 'D' {p.isValidDecimal()}?
    ;

BIGDECIMAL_LITERAL
    : DIGIT+ EXPONENT? 'BD'
    | DECIMAL_DIGITS EXPONENT? 'BD' {p.isValidDecimal()}?
    ;

// Generalize the identifier to give a sensible INVALID_IDENTIFIER error message:
// * Unicode letters rather than a-z and A-Z only
// * URI paths for table references using paths
// We then narrow down to ANSI rules in exitUnquotedIdentifier() in the parser.
IDENTIFIER
    : (UNICODE_LETTER | DIGIT | '_')+
    | UNICODE_LETTER+ '://' (UNICODE_LETTER | DIGIT | '_' | '/' | '-' | '.' | '?' | '=' | '&' | '#' | '%')+
    ;

BACKQUOTED_IDENTIFIER
    : '`' ( ~'`' | '``' )* '`'
    ;

fragment DECIMAL_DIGITS
    : DIGIT+ '.' DIGIT*
    | '.' DIGIT+
    ;

fragment EXPONENT
    : 'E' [+-]? DIGIT+
    ;

fragment DIGIT
    : [0-9]
    ;

fragment LETTER
    : [A-Z]
    ;

fragment UNICODE_LETTER
    : [\p{L}]
    ;

SIMPLE_COMMENT
    : '--' ('\\\n' | ~[\r\n])* '\r'? '\n'? -> channel(HIDDEN)
    ;

BRACKETED_COMMENT
    : '/*' {!p.isHint()}? ( BRACKETED_COMMENT | . )*? ('*/' | {markUnclosedComment(l);} EOF) -> channel(HIDDEN)
    ;

WS
    : [ \t\n\f\r\u000B\u00A0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u2028\u202F\u205F\u3000]+ -> channel(HIDDEN)
    ;

// Catch-all for anything we can't recognize.
// We use this to be able to ignore and recover all the text
// when splitting statements with DelimiterLexer
UNRECOGNIZED
    : .
    ;