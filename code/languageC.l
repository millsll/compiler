%{
//#include<stdlib.h>
#include"syntax.tab.h"
extern int correct;
//node type
typedef enum {
        L_INT,
        L_FLOAT,
        L_ID,
        L_TYPE,
        OTHERS
}NODE_TYPE;
//node definition
struct Node{
        //first child's ptr
        struct Node* firc;
        //next sib's ptr
        struct Node* sib;
        //node's name
        char name[32];
        //node's contant
        union{
                int int_c;
                float float_c;
                char str_c[32];
        };
        int line;
        NODE_TYPE type;
        int Final;
};
struct Node* root;
void newlexnode(char* name,NODE_TYPE type);
//line column 
int yycolumn=1;
#define YY_USER_ACTION\
        yylloc.first_line = yylloc.last_line = yylineno;\
        yylloc.first_column = yycolumn;\
        yylloc.last_column = yycolumn + yyleng -1;\
        yycolumn += yyleng;
%}
%option yylineno
DEC     0|([1-9]+[0-9]*)
OCT     0[0-7]+
OCTE    0[0-7]*[8-9]+[0-9]*
HEX     0[Xx][0-9a-fA-F]+
HEXE    0[Xx][0-9a-fA-F]*[g-zG-Z]+[0-9a-zA-Z]*
FLOAT   [0-9]+\.[0-9]+  
FLOATEXP    ((\.[0-9]+)|([0-9]+\.[0-9]+)|([0-9]+\.)|([0-9]+))([eE][+-]?[0-9]+)
FLOATE  ((\.[0-9]+)|([0-9]+\.[0-9]+)|([0-9]+\.)|([0-9]+))([eE][+-]?)
ID      [a-zA-Z_][a-zA-Z0-9]*
SEMI    ;
COMMA   ,
ASSIGNOP    =
RELOP   >|<|>=|<=|==|!=
PLUS    "+"
MINUS   "-"
STAR    \*
DIV     \/
AND     &&
OR      \|\|
DOT     \.
NOT     !
TYPE    int|float
LP      \(
RP      \)
LB      \[
RB      \]
LC      \{
RC      \}
STRUCT  struct
RETURN  return
IF      if
ELSE    else
WHILE   while
ENTER   \n
WS      [ \t\r]+
%%
{HEX}   {//printf("HEX\n");
         //yylval = strtol(yytext, NULL,16);
         newlexnode("INT",L_INT);
         yylval.node->int_c=strtol(yytext,NULL,16);
         return INT;
        }
{HEXE}  {//printf("HEXERROR\n");
         printf("Error type A at line %d: Illegal hex number: \'%s\'.\n",yylineno,yytext);
         newlexnode("INT",L_INT);
         yylval.node->int_c=0;
         return INT;
        }
{OCT}   {//printf("OCT\n");
         //yylval = strtol(yytext,NULL,8);
         newlexnode("INT",L_INT);
         yylval.node->int_c=strtol(yytext,NULL,8);
         return INT;
        }
{OCTE}  {//printf("OCTERROR\n");
         printf("Error type A at line %d: Illegal oct number: \'%s\'.\n",yylineno,yytext);
         newlexnode("INT",L_INT);
         return INT;
        }
{DEC}   {//printf("DEC\n");
         //yylval = strtol(yytext,NULL,10);
         newlexnode("INT",L_INT);
         yylval.node->int_c=strtol(yytext,NULL,10);
         return INT;
        }
{FLOAT} {//printf("FLOAT\n");
         newlexnode("FLOAT",L_FLOAT);
         yylval.node->float_c = atof(yytext);
         return FLOAT;
        }
{FLOATEXP}  {//printf("FLOATEXP\n");
         newlexnode("FLOAT",L_FLOAT);
         yylval.node->float_c=atof(yytext);
         return FLOAT;
        }
{FLOATE}    {//printf("FLOATERROR\n");
         printf("Error type A at line %d: Illegal floating number: \'%s\'.\n",yylineno,yytext);
         newlexnode("FLOAT",L_FLOAT);
         yylval.node->float_c=0;
         return FLOAT;
        }
{SEMI}  {//printf("SEMI\n");
         newlexnode("SEMI",OTHERS);
         return SEMI;
        }
{COMMA} {//printf("COMMA\n");
         newlexnode("COMMA",OTHERS);
         return COMMA;
        }
{ASSIGNOP}  {//printf("ASSIGNOP\n");
         newlexnode("ASSIGNOP",OTHERS);
         return ASSIGNOP;
        }
{RELOP} {//printf("RELOP\n");
         newlexnode("RELOP",OTHERS);
         return RELOP;
        }
{PLUS}  {//printf("PLUS\n");
         newlexnode("PLUS",OTHERS);
         return PLUS;
        }
{MINUS} {//printf("MINUS\n");
         newlexnode("MINUS",OTHERS);
         return MINUS;
        }
{STAR}  {//printf("STAR\n");
         newlexnode("STAR",OTHERS);
         return STAR;
        }
{DIV}   {//printf("DIV\n");
         newlexnode("DIV",OTHERS);
         return DIV;
        }
{AND}   {//printf("AND\n");
         newlexnode("AND",OTHERS);
         return AND;
        }
{OR}    {//printf("OR\n");
         newlexnode("OR",OTHERS);
         return OR;
        }
{DOT}   {//printf("DOT\n");
         newlexnode("DOT",OTHERS);
         return DOT;
        }
{NOT}   {//printf("NOT\n");
         newlexnode("NOT",OTHERS);
         return NOT;
        }
{TYPE}  {//printf("TYPE\n");
         newlexnode("TYPE",L_TYPE);
         strcpy(yylval.node->str_c,yytext);
         //printf("%s\n",yylval.node->str_c);
         return TYPE;
        }
{LP}    {//printf("LP\n");
         newlexnode("LP",OTHERS);
         return LP;
        }
{RP}    {//printf("RP\n");
         newlexnode("RP",OTHERS);
         return RP;
        }
{LB}    {//printf("LB\n");
         newlexnode("LB",OTHERS);
         return LB;
        }
{RB}    {
         newlexnode("RB",OTHERS);
         return RB;
        }
{LC}    {//printf("LC\n");
         newlexnode("LC",OTHERS);
         return LC;
        }
{RC}    {
         newlexnode("RC",OTHERS);
         return RC;
        }
{STRUCT}    {//printf("STRUCT\n");
         newlexnode("STRUCT",OTHERS);
         return STRUCT;
        }
{RETURN}    {//printf("RETURN\n");
         newlexnode("RETURN",OTHERS);
         return RETURN;
        }
{IF}    {//printf("IF\n");
         newlexnode("IF",OTHERS);
         return IF;
        }
{ELSE}  {//printf("ELSE\n");
         newlexnode("ELSE",OTHERS);
         return ELSE;
        }
{WHILE} {//printf("WHILE\n");
         newlexnode("WHILE",OTHERS);
         return WHILE;
        }
{ID}    {//printf("ID\n");
         newlexnode("ID",L_ID);
         strcpy(yylval.node->str_c,yytext);
         return ID;
        }
{ENTER} {yycolumn = 1;}
{WS}    {;}
.       {printf("Error type A at line %d: Mysterious characters \'%s\'.\n",yylineno,yytext); correct=0;}
%%
void newlexnode(char * name, NODE_TYPE type){
        yylval.node=(struct Node*)malloc(sizeof(struct Node));
        yylval.node->firc=NULL;
        yylval.node->sib=NULL;
        yylval.node->line=yylineno;
        strcpy(yylval.node->name,name);
        yylval.node->type=type;
        yylval.node->Final=1;
}