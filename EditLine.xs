#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <histedit.h>
#include <stdio.h>

#include "const-c.inc"

#define HERE printf("%d\n",__LINE__)

typedef struct EditLine * Term_EditLine;
unsigned char pwrapper (EditLine *, int, unsigned int);

/* user defined functions */
static unsigned char uf00 (EditLine * e, int k) { return pwrapper(e,k,0); }
static unsigned char uf01 (EditLine * e, int k) { return pwrapper(e,k,1); }
static unsigned char uf02 (EditLine * e, int k) { return pwrapper(e,k,2); }
static unsigned char uf03 (EditLine * e, int k) { return pwrapper(e,k,3); }
static unsigned char uf04 (EditLine * e, int k) { return pwrapper(e,k,4); }
static unsigned char uf05 (EditLine * e, int k) { return pwrapper(e,k,5); }
static unsigned char uf06 (EditLine * e, int k) { return pwrapper(e,k,6); }
static unsigned char uf07 (EditLine * e, int k) { return pwrapper(e,k,7); }
static unsigned char uf08 (EditLine * e, int k) { return pwrapper(e,k,8); }
static unsigned char uf09 (EditLine * e, int k) { return pwrapper(e,k,9); }
static unsigned char uf10 (EditLine * e, int k) { return pwrapper(e,k,10); }
static unsigned char uf11 (EditLine * e, int k) { return pwrapper(e,k,11); }
static unsigned char uf12 (EditLine * e, int k) { return pwrapper(e,k,12); }
static unsigned char uf13 (EditLine * e, int k) { return pwrapper(e,k,13); }
static unsigned char uf14 (EditLine * e, int k) { return pwrapper(e,k,14); }
static unsigned char uf15 (EditLine * e, int k) { return pwrapper(e,k,15); }
static unsigned char uf16 (EditLine * e, int k) { return pwrapper(e,k,16); }
static unsigned char uf17 (EditLine * e, int k) { return pwrapper(e,k,17); }
static unsigned char uf18 (EditLine * e, int k) { return pwrapper(e,k,18); }
static unsigned char uf19 (EditLine * e, int k) { return pwrapper(e,k,19); }
static unsigned char uf20 (EditLine * e, int k) { return pwrapper(e,k,20); }
static unsigned char uf21 (EditLine * e, int k) { return pwrapper(e,k,21); }
static unsigned char uf22 (EditLine * e, int k) { return pwrapper(e,k,22); }
static unsigned char uf23 (EditLine * e, int k) { return pwrapper(e,k,23); }
static unsigned char uf24 (EditLine * e, int k) { return pwrapper(e,k,24); }
static unsigned char uf25 (EditLine * e, int k) { return pwrapper(e,k,25); }
static unsigned char uf26 (EditLine * e, int k) { return pwrapper(e,k,26); }
static unsigned char uf27 (EditLine * e, int k) { return pwrapper(e,k,27); }
static unsigned char uf28 (EditLine * e, int k) { return pwrapper(e,k,28); }
static unsigned char uf29 (EditLine * e, int k) { return pwrapper(e,k,29); }
static unsigned char uf30 (EditLine * e, int k) { return pwrapper(e,k,30); }
static unsigned char uf31 (EditLine * e, int k) { return pwrapper(e,k,31); }

static struct ufe {
  unsigned char (*cwrapper)(EditLine * , int);
  SV *pfunc;
} uf_tbl[] = {
  { uf00, NULL },
  { uf01, NULL },
  { uf02, NULL },
  { uf03, NULL },
  { uf04, NULL },
  { uf05, NULL },
  { uf06, NULL },
  { uf07, NULL },
  { uf08, NULL },
  { uf09, NULL },
  { uf10, NULL },
  { uf11, NULL },
  { uf12, NULL },
  { uf13, NULL },
  { uf14, NULL },
  { uf15, NULL },
  { uf16, NULL },
  { uf17, NULL },
  { uf18, NULL },
  { uf19, NULL },
  { uf20, NULL },
  { uf21, NULL },
  { uf22, NULL },
  { uf23, NULL },
  { uf24, NULL },
  { uf25, NULL },
  { uf26, NULL },
  { uf27, NULL },
  { uf28, NULL },
  { uf29, NULL },
  { uf30, NULL },
  { uf31, NULL }
};

typedef struct _histedit {
  EditLine * el;
  History  *hist;
  SV *promptSV;
  SV *rpromptSV;
  char *prompt;
  char *rprompt;
} HistEdit;

static SV *el_callback;

unsigned char pwrapper (EditLine * e, int k, unsigned int id)
{

  dSP;

  SV *el;
  int count;
  int ret = CC_NORM;

  if(id < 32) {
    if(uf_tbl[id].pfunc != NULL) {

      dXSTARG;

/*       el = sv_newmortal(); */
/*       sv_setref_pv(el, "Term::EditLine", (void*)e); */

      ENTER;
      SAVETMPS;

      PUSHMARK(SP);
      XPUSHs(el_callback);
      XPUSHi(k);
      PUTBACK;

      count = perl_call_sv(uf_tbl[id].pfunc,G_SCALAR);

      SPAGAIN;

      if(count != 1) {
	croak ("Term::EditLine: internal error\n");
      }

      ret = POPi;

      PUTBACK;
      FREETMPS;
      LEAVE;

    }
  }
  return (unsigned char)ret;
}


static SV * promptSV;
static SV * rpromptSV;
static char *prompt = NULL;
static char *rprompt = NULL;
static History *hist = NULL;

char * promptfunc (EditLine * e)
{
  if (promptSV == NULL)
    if (prompt != NULL)
      return prompt;
    else
      return NULL;

  dSP;

  SV *el;
  SV *svret;
  int count;
  STRLEN len;

/*   el = sv_newmortal(); */
/*   sv_setref_pv(el, "Term::EditLine", (void*)e); */

  ENTER;
  SAVETMPS;

  PUSHMARK(SP);
  XPUSHs(el_callback);
  PUTBACK;
  count = perl_call_sv(promptSV,G_SCALAR);

  SPAGAIN;

  if (count != 1) {
    croak("Term::EditLine: error calling prompt function\n");
  }

  svret = POPs;
  if(SvPOK(svret)) {
    prompt = malloc(SvLEN(svret)+1);
    strcpy(prompt,SvPV(svret,PL_na));
  }

  PUTBACK;
  FREETMPS;
  LEAVE;
  return prompt;
}

char * rpromptfunc (EditLine * e)
{
  if (rpromptSV == NULL)
    if (rprompt != NULL)
      return rprompt;
    else
      return NULL;

  dSP;

  SV *el;
  SV *svret;
  int count;
  STRLEN len;

  //el = sv_newmortal();
  //sv_setref_pv(el, "Term::EditLine", (void*)e);

  ENTER;
  SAVETMPS;

  PUSHMARK(SP);
  XPUSHs(el_callback);
  PUTBACK;
  count = perl_call_sv(rpromptSV,G_SCALAR);

  SPAGAIN;

  if (count != 1) {
    croak("Term::EditLine: error calling prompt function\n");
  }

  svret = POPs;
  if(SvPOK(svret)) {
    rprompt = malloc(SvLEN(svret)+1);
    strcpy(rprompt,SvPV(svret,PL_na));
  }

  PUTBACK;
  FREETMPS;
  LEAVE;
  return rprompt;
}

MODULE = Term::EditLine		PACKAGE = Term::EditLine   PREFIX = el_
INCLUDE: const-xs.inc

void
el_beep(editline)
	EditLine * 	editline

void
el_deletestr(editline, count)
	EditLine * 	editline
	int		count

int
el_get(editline, arg1, arg2)
	EditLine * 	editline
	int	arg1
	void *	arg2

char 
el_getc(editline)
	EditLine * 	editline
PREINIT:
  char *ch;
  int ret;
CODE:
{
  HERE;
  ch = malloc(1);
  ret = el_getc(editline,ch);
  if (ret == -1)
    RETVAL = NULL;
  else {
    RETVAL = ch;
  }
}

void
el_gets(editline)
	EditLine * editline
PROTOTYPE: $
PREINIT:
  int count;
  const char *line;
PPCODE:
{
  line = el_gets(editline,&count);
  EXTEND(sp,2);
  if (line != NULL) {
    PUSHs(sv_2mortal(newSVpvn(line,count)));
  } else {
    PUSHs(&PL_sv_undef);
  }
}

EditLine *
el_new(pkg,name,fin=stdin,fout=stdout,ferr=stderr)
     char *     pkg
     char *     name
     FILE *	fin
     FILE *	fout
     FILE *	ferr
PREINIT:
   HistEvent ev;
CODE:
{
  RETVAL = el_init(name, fin, fout, ferr);
  ST(0) = sv_newmortal();
  sv_setref_pv(ST(0),"Term::EditLine",(void*)RETVAL);
  el_callback = ST(0);

  hist = history_init();
  history (hist,&ev,H_SETSIZE,100);
  el_set(RETVAL,EL_HIST,history,hist);

  el_source(RETVAL, NULL);
}

void el_DESTROY(editline)
     EditLine *editline
CODE:
{
  if(prompt != NULL)
    free(prompt);  
  if(rprompt != NULL)
    free(rprompt);
  if(promptSV != NULL)
    sv_clear(promptSV);
  if(rpromptSV != NULL)
    sv_clear(rpromptSV);
  el_end(editline);
  history_end(hist);
}

void
el_set_history_set_size(editline,size)
         EditLine *editline
         int size
PREINIT:
HistEvent ev;
CODE:
{
  history(hist,&ev,H_SETSIZE,size);
}

void
el_history_enter(editline,str)
     EditLine *editline
     char *str
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_ENTER,str);
}

void
el_history_append (editline,str)
     EditLine *editline
     char *str
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_APPEND,str);
}

void
el_history_add (editline,str)
     EditLine *editline
     char *str
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_ADD,str);
}

int
el_history_get_size (editline)
     EditLine *editline
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_GETSIZE);
  RETVAL = ev.num;
}

void
el_history_clear (editline)
     EditLine *editline
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_CLEAR);
}

const char *
el_history_get_first(editline)
     EditLine *editline
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_FIRST);
  RETVAL = ev.str;
}

const char *
el_history_get_last(editline)
     EditLine *editline
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_LAST);
  RETVAL = ev.str;
}

const char *
el_history_get_prev(editline)
     EditLine *editline
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_PREV);
  RETVAL = ev.str;
}


const char *
el_history_get_next(editline)
     EditLine *editline
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_NEXT);
  RETVAL = ev.str;
}


const char *
el_history_get_curr(editline)
     EditLine *editline
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_CURR);
  RETVAL = ev.str;
}

void
el_history_set(editline)
     EditLine *editline
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_SET);
}

const char *
el_history_get_prev_str(editline,str)
     EditLine *editline
     char *str
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_PREV_STR,str);
  RETVAL = ev.str;
}

const char *
el_history_get_next_str(editline,str)
     EditLine *editline
     char *str
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_NEXT_STR,str);
  RETVAL = ev.str;
}

void
el_history_load(editline,str)
     EditLine *editline
     char *str
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_LOAD,str);
}

void
el_history_save(editline,str)
     EditLine *editline
     char *str
PREINIT:
  HistEvent ev;
CODE:
{
  history(hist,&ev,H_SAVE,str);
}

int
el_insertstr(editline, str)
	EditLine * 	editline
	char *		str

const LineInfo *
el_line(editline)
	EditLine * 	editline

int el_parse(editline,...)
        EditLine * editline
PREINIT:
  int alen,i;
  char **argv;
  char* tmp;
  STRLEN len;
CODE:
{
  if (items > 1) {

    argv = malloc(sizeof(char*)*items);
    
    alen = items - 1;

    for(i=1;i<items;i++) {
      if(SvPOK(ST(i))) {
	argv[i-1] = SvPV(ST(i),len);
      } else {
	argv[i-1] = NULL;
      }
    }

    argv[alen] = NULL;

    RETVAL = el_parse(editline,alen,argv);

    free(argv);

  } else {
    RETVAL = -1;
  }
}

void
el_push(editline, arg1)
	EditLine * 	editline
	char *	arg1

void
el_reset(editline)
	EditLine * 	editline

void
el_resize(editline)
	EditLine * 	editline


int el_set_prompt(editline, func)
     EditLine * editline
     SV * func
CODE:
{
  if(strcmp(sv_reftype(SvRV(func),0),"CODE") == 0) {
    promptSV = newSVsv(func);
    RETVAL = el_set(editline,EL_PROMPT,promptfunc);
  } else {
    if(promptSV != NULL)
      sv_clear(promptSV);
    if(SvPOK(func)) {
      prompt = malloc(SvLEN(func)+1);
      strcpy(prompt,SvPV(func,PL_na));
    }
    RETVAL = el_set(editline,EL_PROMPT,promptfunc);
  }
}

int el_set_rprompt(editline, func)
     EditLine * editline
     SV * func
CODE:
{
  if(strcmp(sv_reftype(SvRV(func),0),"CODE") == 0) {
    rpromptSV = newSVsv(func);
    RETVAL = el_set(editline,EL_RPROMPT,rpromptfunc);
  } else {
    if(rpromptSV != NULL)
      sv_clear(rpromptSV);
    if(SvPOK(func)) {
      rprompt = malloc(SvLEN(func)+1);
      strcpy(rprompt,SvPV(func,PL_na));
    }
    RETVAL = el_set(editline,EL_PROMPT,rpromptfunc);
  }
}

SV * el_get_prompt(editline)
     EditLine *editline
CODE:
{
  if(promptSV != NULL)
    RETVAL = promptSV;
  else if(prompt != NULL)
    RETVAL = newSVpv(prompt,0);
  else 
    RETVAL = &PL_sv_undef;
}

SV * el_get_rprompt(editline)
     EditLine *editline
CODE:
{
  if(rpromptSV != NULL)
    RETVAL = rpromptSV;
  else if(rprompt != NULL)
    RETVAL = newSVpv(rprompt,0);
  else 
    RETVAL = &PL_sv_undef;
}

int el_set_editor(editline,mode)
     EditLine * editline
     char *mode
CODE:
{
  RETVAL = el_set(editline,EL_EDITOR,mode);
}

int el_add_fun (editline,name,help,sub)
     EditLine * editline
     char *name
     char *help
     SV *sub
PREINIT:
  int i;
CODE:
{
  for(i=0;i<32;i++)
    if(uf_tbl[i].pfunc == NULL) {
      uf_tbl[i].pfunc = newSVsv(sub);
      break;
    }

  if(i == 32) {
    croak("Term::EditLine: Error: you can only add up to 32 functions\n");
    RETVAL = -1;
  } else {
    RETVAL = el_set(editline,EL_ADDFN,name,help,uf_tbl[i].cwrapper);
  }
}


int
el_source(editline, arg1)
	EditLine * 	editline
	const char *	arg1
