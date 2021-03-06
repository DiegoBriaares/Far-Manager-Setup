/*==========================================================================*/
/*
@@INCLUDE:$\templates\source\header-base@@
*/
/*--------------------------------------------------------------------------*/
/*
@@INCLUDE:$\templates\source\header-gnu@@
*/
/*--------------------------------------------------------------------------*/
/*
@@INCLUDE:$\templates\source\header-cvs@@
*/
/*==========================================================================*/
/*                             Parser settinds                              */
/*==========================================================================*/
%option noyywrap
/*==========================================================================*/
/*                           Parser definitions                             */
/*==========================================================================*/
%{
#define LBR	1
#define RBR	2
#define ADD	3
#define SUB	4
#define MUL	5
#define DIV	6
#define MOD	7
#define NUMBER	8
void yycount(void);
void yyerror(char *error, ...);
%}
/*==========================================================================*/
/*                             Parser aliases                               */
/*==========================================================================*/
DIGIT		[0-9]
NUMBER		{DIGIT}+(\.{DIGIT}+)?(E[+\-]?{DIGIT}+)?
COMENT1		"//".*$
COMENT2		"/*".*?"*/"
DELIMITER	[\t\r\n ]
SPACE		{DELIMITER}+
/*==========================================================================*/
/*                           Parser tokens list                             */
/*==========================================================================*/
%%
@@HERE@@<<EOF>>		{ yycount(); return EOF;					}
"("		{ yycount(); return LBR;					}
")"		{ yycount(); return RBR;					}
"+"		{ yycount(); return ADD;					}
"-"		{ yycount(); return SUB;					}
"*"		{ yycount(); return MUL;					}
"/"		{ yycount(); return DIV;					}
"%"		{ yycount(); return MOD;					}
{NUMBER}	{ yycount(); return NUMBER;					}
{COMENT1}	{ yycount();							}
{COMENT2}	{ yycount();							}
{SPACE}		{ yycount();							}
.		{ yycount(); yyerror("Unknown character!");			}
%%
/*==========================================================================*/
/*                         Parser error handling                            */
/*==========================================================================*/
unsigned errorpos = 0;			// Error scan position in line
unsigned errorline = 1;			// Error scan line
char errorbuffer[256];			// Error buffer
/*--------------------------------------------------------------------------*/
// Function yycount makes pretty error messages by yycounting characters and
// saving them in a global errorbuffer. So yyerror() below knows about the
// buffer and can print out the partial line with the error.
void yycount(void)
{
	unsigned i, j;
	static char *err = errorbuffer;
	for (i = 0; yytext[i] != '\0'; i++)
	{
		if (yytext[i] == '\n')
		{
			errorpos = 0;
			errorline++;
			for (j = 0; j < 256; j++)
				errorbuffer[j] = 0;
			err = errorbuffer;
		}
		else
		{
			*err++ = yytext[i];
			if (yytext[i] == '\t')
				errorpos += 8 - (errorpos & (8 - 1));
			else
				errorpos++;
		}
	}
}
/*--------------------------------------------------------------------------*/
void yyerror(char *error, ...)
{
	fprintf(stdout, "%s\n", errorbuffer);
	fprintf(stdout, "%*s---[", errorpos, "^");
	fprintf(stdout, "%d:%d]\n", errorline, errorpos);
	exit(0);
}
/*==========================================================================*/
/*                        Parser main function                              */
/*==========================================================================*/
int main(int argc, char* argv[], char* envp[])
{
	int token;

	// Skip over program name
	--argc;
	++argv;

	// Setting input stream
	if (argc > 0)
		yyin = fopen(argv[0], "r");
	else
		yyin = stdin;

	// Lexical parsing
	while ((token = yylex()) != EOF)
		fprintf(stdout, "%d\n", token);
}
/*==========================================================================*/
