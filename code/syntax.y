%{
#include<stdio.h>
#include<stdarg.h>
extern int yylineno;
int yylex();
int yyerror(char*);
int correct=1;
struct Node* newbisonnode(char * name, int line);
void connect(struct Node* parent,int num,...);
void outputtree(struct Node* root,int dpt);
extern struct Node* root;
%}
%union{
    struct Node* node;
}
%locations
/*declared tokens*/
%token <node>INT
%token <node>FLOAT
%token <node>ID
%token <node>SEMI
%token <node>COMMA
%token <node>ASSIGNOP
%token <node>RELOP
%token <node>PLUS
%token <node>MINUS
%token <node>STAR
%token <node>DIV
%token <node>AND
%token <node>OR
%token <node>DOT
%token <node>NOT
%token <node>TYPE
%token <node>LP
%token <node>RP
%token <node>LB
%token <node>RB
%token <node>LC
%token <node>RC
%token <node>STRUCT
%token <node>RETURN
%token <node>IF
%token <node>ELSE
%token <node>WHILE
//High-level Definitions
%type <node>Program
%type <node>ExtDefList
%type <node>ExtDef
%type <node>ExtDecList
//Specifiers
%type <node>Specifier
%type <node>StructSpecifier
%type <node>OptTag
%type <node>Tag
//Declarators
%type <node>VarDec
%type <node>FunDec
%type <node>VarList
%type <node>ParamDec
//Statements
%type <node>CompSt
%type <node>StmtList
%type <node>Stmt
//Local Dfinitions
%type <node>DefList
%type <node>Def
%type <node>DecList
%type <node>Dec
//Expressions
%type <node>Exp
%type <node>Args
//
%start Program
%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left SATR DIV
%right NOT
%left NMINUS
%left DOT
%left LB RB
%left LP RP
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%%
//High-level Definitions
Program : ExtDefList {
        $$=newbisonnode("Program",@$.first_line);
        connect($$,1,$1);
        root=$$;
    }
    ;
ExtDefList : ExtDef ExtDefList {
        $$=newbisonnode("ExtDefList",@$.first_line);
        connect($$,2,$1,$2);
    }
    | /*empty*/ {
        $$=NULL;
    }
    ;
ExtDef : Specifier ExtDecList SEMI {
        $$=newbisonnode("ExtDef",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | Specifier SEMI {
        $$=newbisonnode("ExtDef",@$.first_line);
        connect($$,2,$1,$2);
    }
    | Specifier FunDec CompSt {
        $$=newbisonnode("ExtDef",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | error SEMI {yyerror("Wrong type");}
    | Specifier error SEMI {;}
    //| Specifier error {yyerror("Missing \';\'");}
    | error Specifier SEMI {;}
    ;
ExtDecList : VarDec {
        $$=newbisonnode("ExtDecList",@$.first_line);
        connect($$,1,$1);
    }
    | VarDec COMMA ExtDecList {
        $$=newbisonnode("ExtDecList",@$.first_line);
        connect($$,2,$1,$2,$3);
    }
    | VarDec error ExtDefList {
        yyerror("Missing \',\'");
    }
    ;
//Specifiers
Specifier : TYPE {
        $$=newbisonnode("Specifier",@$.first_line);
        connect($$,1,$1);
    }
    | StructSpecifier {
        $$=newbisonnode("Specifier",@$.first_line);
        connect($$,1,$1);
    }
    ;
StructSpecifier : STRUCT OptTag LC DefList  RC {
        $$=newbisonnode("StructSpecifier",@$.first_line);
        connect($$,5,$1,$2,$3,$4,$5);
    }
    | STRUCT Tag {
        $$=newbisonnode("StructSpecifier",@$.first_line);
        connect($$,2,$1,$2);
    }
    ;
OptTag : ID {
        $$=newbisonnode("OptTag",@$.first_line);
        connect($$,1,$1);
    }
    | /*empty*/ {
        $$=NULL;
    }
    ;
Tag : ID {
        $$=newbisonnode("ID",@$.first_line);
        connect($$,1,$1);
    }
    ;
//Declarators
VarDec : ID {
        $$=newbisonnode("VarDec",@$.first_line);
        connect($$,1,$1);
    }
    | VarDec LB INT RB {
        $$=newbisonnode("VarDec",@$.first_line);
        connect($$,4,$1,$2,$3,$4);
    }
    | VarDec LB error RB {
        yyerror("Missing \']\'");
    }
    ;
FunDec : ID LP VarList RP {
        $$=newbisonnode("FunDec",@$.first_line);
        connect($$,4,$1,$2,$3,$4);
    }
    | ID LP RP {
        $$=newbisonnode("FunDec",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | ID LP error RP {
        yyerror("Wrong arguments");
    }
    | error LP VarList RP {
        yyerror("Wrong Function name");
    }
    ;
VarList : ParamDec COMMA VarList {
        $$=newbisonnode("VarList",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | ParamDec{
        $$=newbisonnode("VarList",@$.first_line);
        connect($$,1,$1);
    }
    ;
ParamDec : Specifier VarDec {
        $$=newbisonnode("ParamDec",@$.first_line);
        connect($$,2,$1,$2);
    }
    ;
//Statements
CompSt : LC DefList StmtList RC {
        $$=newbisonnode("CompSt",@$.first_line);
        connect($$,4,$1,$2,$3,$4);
    }
    ;
StmtList : Stmt StmtList {
        $$=newbisonnode("StmtList",@$.first_line);
        connect($$,2,$1,$2);
    }
    | /*empty*/ {$$=NULL;}
    ;
Stmt : Exp SEMI {
        $$=newbisonnode("Stmt",@$.first_line);
        connect($$,2,$1,$2);
    }
    | CompSt {
        $$=newbisonnode("Stmt",@$.first_line);
        connect($$,1,$1);
    }
    | RETURN Exp Stmt {
        $$=newbisonnode("Stmt",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | IF LP Exp RP Stmt %prec LOWER_THAN_ELSE {
        $$=newbisonnode("Stmt",@$.first_line);
        connect($$,5,$1,$2,$3,$4,$5);
    }
    | IF LP Exp RP Stmt ELSE Stmt {
        $$=newbisonnode("Stmt",@$.first_line);
        connect($$,7,$1,$2,$3,$4,$5,$6,$7);
    }
    | WHILE LP Exp RP Stmt {
        $$=newbisonnode("Stmt",@$.first_line);
        connect($$,5,$1,$2,$3,$4,$5);
    }
    | error SEMI {
        yyerror("Wrong expression or Definition");
    }
    | Exp error SEMI {
        yyerror("Missing \';\'");
    }
    | RETURN Exp error {
        yyerror("Missing \';\'");
    }
    | RETURN error SEMI {
        yyerror("Wrong return value");
    }
    ;
//Local Definitions
DefList : Def DefList {
        $$=newbisonnode("DefList",@$.first_line);
        connect($$,2,$1,$2);
    }
    | /*empty*/ {
        $$=NULL;
    }
    ;
Def : Specifier DecList SEMI {
        $$=newbisonnode("Def",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | Specifier error SEMI {
        yyerror("Missing identifier");
    }
    | Specifier DecList error {
        yyerror("Missing \';\'");
    }
    ;
DecList : Dec {
        $$=newbisonnode("DecList",@$.first_line);
        connect($$,1,$1);
    }
    | Dec COMMA DecList {
        $$=newbisonnode("DecList",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    ;
Dec : VarDec {
        $$=newbisonnode("Dec",@$.first_line);
        connect($$,1,$1);
    }
    | VarDec ASSIGNOP Exp{
        $$=newbisonnode("Dec",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    ;
//Expression
Exp : Exp ASSIGNOP Exp {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | Exp AND Exp {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | Exp OR Exp {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | Exp RELOP Exp {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | Exp PLUS Exp {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | Exp MINUS Exp {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | Exp STAR Exp {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | Exp DIV Exp {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | LP Exp RP {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | MINUS Exp %prec NMINUS{
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,2,$1,$2);
    }
    | NOT Exp {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,2,$1,$2);
    }
    | ID LP Args RP {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,4,$1,$2,$3,$4);
    }
    | ID LP RP {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | Exp LB Exp RB {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,4,$1,$2,$3,$4);
    }
    | Exp DOT ID {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | ID {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,1,$1);
    }
    | INT {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,1,$1);
    }
    | FLOAT {
        $$=newbisonnode("Exp",@$.first_line);
        connect($$,1,$1);
    }
    | Exp ASSIGNOP error {
        yyerror("Wrong expression");
    }
    | Exp AND error {
        yyerror("Wrong expression");
    }
    | Exp OR error {
        yyerror("Wrong expression");
    }
    | Exp RELOP error {
        yyerror("Wrong expression");
    }
    | Exp PLUS error {
        yyerror("Wrong expression");
    }
    | Exp MINUS error {
        yyerror("Wrong expression");
    }
    | Exp STAR error {
        yyerror("Wrong expression");
    }
    | Exp DIV  error {
        yyerror("Wrong expression");
    }
    | LP error RP {
        yyerror("Wrong expression");
    }
    | MINUS error {
        yyerror("Wrong expression");
    }
    | NOT error {
        yyerror("Wrong expression");
    }
    | ID LP error RP {
        yyerror("Wrong arguments");
    }
    | Exp LB error RB {
        yyerror("Missing \']\'");
    }
    ;
Args : Exp COMMA Args {
        $$=newbisonnode("Args",@$.first_line);
        connect($$,3,$1,$2,$3);
    }
    | Exp {
        $$=newbisonnode("Args",@$.first_line);
        connect($$,1,$1);
    }
    ;
%%
#include "lex.yy.c"

int yyerror(char * msg){
    correct=0;
    if(msg[0]=='s'&&msg[1]=='y'&&msg[2]=='n'){
        printf("Error type B at Line %d: %s.\n",yylineno,msg);
    }
    else {
        printf(" %s.\n",msg);
    }
}
struct Node* newbisonnode(char *name, int line){
    struct Node* N=(struct Node*)malloc(sizeof(struct Node));
    N->firc=NULL;
    N->sib=NULL;
    strcpy(N->name,name);
    N->type=OTHERS;
    N->line=line;
    N->Final=0;
    return N;
}
void connect(struct Node* parent, int num,...){
    va_list args;
    va_start(args,num);
    struct Node* p=va_arg(args,struct Node*);
    parent->firc=p;
    for(int i=1;i<num;i++){
        p->sib=va_arg(args,struct Node*);
        if(p->sib!=NULL)p=p->sib;
    }
}
void outputtree(struct Node* root,int dpt){
    if(root!=NULL){
        for(int i=0;i<dpt;i++){
            printf("\t");
        }
        printf("%s",root->name);
        if(root->Final==0){
            printf(": (%d)",root->line);    
        }
        else{
            if(root->type==L_INT){
                printf(": %d",root->int_c);
            }
            else if(root->type==L_FLOAT){
                printf(": %f",root->float_c);
            }
            else if(root->type==L_ID||root->type==L_TYPE){
                printf(": %s",root->str_c);
            }
        }
        printf("\n");
        outputtree(root->firc,dpt+1);
        outputtree(root->sib,dpt);
    }
}