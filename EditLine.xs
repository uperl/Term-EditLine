#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <histedit.h>
#include <stdio.h>

#include "const-c.inc"

#define HERE printf("%d\n",__LINE__)

unsigned char pwrapper (EditLine *, int, unsigned int);

typedef struct _HistEdit {
  EditLine * el;    /* the editline struct */
  History  *hist;   /* the history struct */
  SV *el_ref;       /* perl reference of the editline struct */
  SV *promptSv;     /* perl prompt subref */
  SV *rpromptSv;    /* perl rprompt subref */
  char *prompt; 
  char *rprompt;
} HistEdit;

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

unsigned char pwrapper (EditLine * e, int k, unsigned int id)
{

  dSP;

  HistEdit *he;
  int count;
  int ret = CC_NORM;

  if(id < 32) {
    if(uf_tbl[id].pfunc != NULL) {

      el_get(e,EL_CLIENTDATA,&he);

      dXSTARG;

      ENTER;
      SAVETMPS;

      PUSHMARK(SP);
      XPUSHs(he->el_ref);
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

/* static SV * promptSV; */
/* static SV * rpromptSV; */
/* static char *prompt = NULL; */
/* static char *rprompt = NULL; */
/* static History *hist = NULL; */

char *
pvsubwrapper(HistEdit *he, SV *sub, char *def)
{
  dSP;
  SV *svret;
  int count,a,b;
  STRLEN len;

  if (sub == NULL)
    return def;

  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(he->el_ref);
  PUTBACK;

  count = perl_call_sv(sub,G_SCALAR);

  SPAGAIN;

  if (count != 1)
    croak ("Term::EditLine: error calling perl sub\n");

  svret = POPs;

  if(SvPOK(svret)) {

    b = SvLEN(svret);

    if(def == NULL)
      def = malloc(b+1);
    else if ((a = strlen(def)) < b)
      def = realloc(def,b-a);

    Copy(SvPV(svret,PL_na),def,b,char);
    *(def+b) = '\0';

  }

  PUTBACK;
  FREETMPS;
  LEAVE;
  return def;
}

char *promptfunc (EditLine *e)
{
  HistEdit *he;
  el_get(e,EL_CLIENTDATA,&he);
  return pvsubwrapper(he,he->promptSv,he->prompt);
}

char *rpromptfunc (EditLine *e)
{
  HistEdit *he;
  el_get(e,EL_CLIENTDATA,&he);
  return pvsubwrapper(he,he->rpromptSv,he->rprompt);
}

/* char * promptfunc (EditLine * e) */
/* { */
/*   SV *el; */
/*   if (promptSV == NULL) */
/*       return prompt; */

/*   dSP; */

/*   SV *svret; */
/*   int count; */
/*   STRLEN len; */
  
/*   el_get(e,EL_CLIENTDATA,&el); */

/*   ENTER; */
/*   SAVETMPS; */

/*   PUSHMARK(SP); */
/*   XPUSHs(el); */
/*   PUTBACK; */
/*   count = perl_call_sv(promptSV,G_SCALAR); */

/*   SPAGAIN; */

/*   if (count != 1) { */
/*     croak("Term::EditLine: error calling prompt function\n"); */
/*   } */

/*   svret = POPs; */
/*   if(SvPOK(svret)) { */
/*     prompt = malloc(SvLEN(svret)+1); */
/*     strcpy(prompt,SvPV(svret,PL_na)); */
/*   } */

/*   PUTBACK; */
/*   FREETMPS; */
/*   LEAVE; */
/*   return prompt; */
/* } */

/* char * rpromptfunc (EditLine * e) */
/* { */
/*   if (rpromptSV == NULL) */
/*     if (rprompt != NULL) */
/*       return rprompt; */
/*     else */
/*       return NULL; */

/*   dSP; */

/*   SV *el; */
/*   SV *svret; */
/*   int count; */
/*   STRLEN len; */

/*   el_get(e,EL_CLIENTDATA,&el); */

/*   ENTER; */
/*   SAVETMPS; */

/*   PUSHMARK(SP); */
/*   XPUSHs(el); */
/*   PUTBACK; */
/*   count = perl_call_sv(rpromptSV,G_SCALAR); */

/*   SPAGAIN; */

/*   if (count != 1) { */
/*     croak("Term::EditLine: error calling prompt function\n"); */
/*   } */

/*   svret = POPs; */
/*   if(SvPOK(svret)) { */
/*     rprompt = malloc(SvLEN(svret)+1); */
/*     strcpy(rprompt,SvPV(svret,PL_na)); */
/*   } */

/*   PUTBACK; */
/*   FREETMPS; */
/*   LEAVE; */
/*   return rprompt; */
/* } */

MODULE = Term::EditLine		PACKAGE = Term::EditLine   PREFIX = el_
INCLUDE: const-xs.inc

void
el_beep(he)
	HistEdit * 	he
CODE:
{
  el_beep(he->el);
}

void
el_deletestr(he, count)
	HistEdit * 	he
	int		count
CODE:
{
  el_deletestr(he->el,count);
}

char 
el_getc(he)
	HistEdit * 	he
PREINIT:
  char *ch;
  int ret;
CODE:
{
  RETVAL = el_getc(he->el,ch);
}

void
el_gets(he)
	HistEdit* he
PREINIT:
  int count;
  const char *line;
PPCODE:
{
  line = el_gets(he->el,&count);

  dXSTARG;
  if (line != NULL)
    XPUSHp(line,count);
  else
    XPUSHs(&PL_sv_undef);
}

HistEdit *
el_new(pkg,name,fin=stdin,fout=stdout,ferr=stderr)
     char *     pkg
     char *     name
     FILE *	fin
     FILE *	fout
     FILE *	ferr
PREINIT:
   HistEvent ev;
   SV *el;
CODE:
{

  RETVAL = malloc(sizeof(HistEdit));
  
  RETVAL->el = el_init(name, fin, fout, ferr);
  RETVAL->el_ref = newSVsv(sv_newmortal());
  sv_setref_pv(RETVAL->el_ref,"Term::EditLine",(void*)RETVAL);  

  RETVAL->promptSv = NULL;
  RETVAL->prompt = NULL;
  RETVAL->rpromptSv = NULL;
  RETVAL->rprompt = NULL;

  ST(0) = RETVAL->el_ref;

  RETVAL->hist = history_init();
  history (RETVAL->hist,&ev,H_SETSIZE,100);

  el_set(RETVAL->el,EL_HIST,history,RETVAL->hist);
  el_set(RETVAL->el,EL_CLIENTDATA,RETVAL);

  el_source(RETVAL->el, NULL);
}

void el_DESTROY(he)
     HistEdit *he
PREINIT:
SV *el;
CODE:
{
  if(he->prompt != NULL)
    free(he->prompt);  
  if(he->rprompt != NULL)
    free(he->rprompt);
  if(he->promptSv != NULL) {
    sv_free(he->promptSv);
  }
  if(he->rpromptSv != NULL)
    sv_free(he->rpromptSv);

  sv_free(he->el_ref);
  el_end(he->el);
  history_end(he->hist);
  free(he);
}

void
el_set_history_set_size(he,size)
         HistEdit *he
         int size
PREINIT:
HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_SETSIZE,size);
}

void
el_history_enter(he,str)
     HistEdit *he
     char *str
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_ENTER,str);
}

void
el_history_append (he,str)
     HistEdit *he
     char *str
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_APPEND,str);
}

void
el_history_add (he,str)
     HistEdit *he
     char *str
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_ADD,str);
}

int
el_history_get_size (he)
     HistEdit *he
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_GETSIZE);
  RETVAL = ev.num;
}

void
el_history_clear (he)
     HistEdit *he
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_CLEAR);
}

const char *
el_history_get_first(he)
     HistEdit *he
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_FIRST);
  RETVAL = ev.str;
}

const char *
el_history_get_last(he)
     HistEdit *he
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_LAST);
  RETVAL = ev.str;
}

const char *
el_history_get_prev(he)
     HistEdit *he
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_PREV);
  RETVAL = ev.str;
}


const char *
el_history_get_next(he)
     HistEdit *he
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_NEXT);
  RETVAL = ev.str;
}


const char *
el_history_get_curr(he)
     HistEdit *he
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_CURR);
  RETVAL = ev.str;
}

void
el_history_set(he)
     HistEdit *he
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_SET);
}

const char *
el_history_get_prev_str(he,str)
     HistEdit *he
     char *str
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_PREV_STR,str);
  RETVAL = ev.str;
}

const char *
el_history_get_next_str(he,str)
     HistEdit *he
     char *str
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_NEXT_STR,str);
  RETVAL = ev.str;
}

void
el_history_load(he,str)
     HistEdit *he
     char *str
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_LOAD,str);
}

void
el_history_save(he,str)
     HistEdit *he
     char *str
PREINIT:
  HistEvent ev;
CODE:
{
  history(he->hist,&ev,H_SAVE,str);
}

int
el_insertstr(he, str)
	HistEdit * 	he
	char *		str
CODE:
{
  RETVAL = el_insertstr(he->el,str);
}

void
el_line(he)
     HistEdit * 	he
PREINIT:
     const LineInfo *le;
PPCODE:
{
  le = el_line(he->el);
  EXTEND(sp,3);
  PUSHs(sv_2mortal(newSVpv(le->buffer,0)));
  PUSHs(sv_2mortal(newSViv(le->cursor - le->buffer)));
  PUSHs(sv_2mortal(newSViv(le->lastchar - le->buffer)));
}

int el_parse(he,...)
        HistEdit * he
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

    RETVAL = el_parse(he->el,alen,argv);

    free(argv);

  } else {
    RETVAL = -1;
  }
}

void
el_push(he, arg1)
	HistEdit * he
	char *	arg1
CODE:
{
  el_push(he->el,arg1);
}

void
el_reset(he)
	HistEdit * 	he
CODE:
{
  el_reset(he->el);
}

void
el_resize(he)
	HistEdit * 	he
CODE:
{
  el_resize(he->el);
}


int el_set_prompt(he, func)
     HistEdit * he
     SV * func
CODE:
{
  if(strcmp(sv_reftype(SvRV(func),0),"CODE") == 0) {
    he->promptSv = newSVsv(func);
    RETVAL = el_set(he->el,EL_PROMPT,promptfunc);
  } else {
    if(he->promptSv != NULL) {
      sv_free(he->promptSv);
      he->promptSv = NULL;
    }
    if(SvPOK(func)) {
      he->prompt = malloc(SvLEN(func)+1);
      strcpy(he->prompt,SvPV(func,PL_na));
    }
    RETVAL = el_set(he->el,EL_PROMPT,promptfunc);
  }
}

int el_set_rprompt(he, func)
     HistEdit * he
     SV * func
CODE:
{
  if(strcmp(sv_reftype(SvRV(func),0),"CODE") == 0) {
    he->rpromptSv = newSVsv(func);
    RETVAL = el_set(he->el,EL_RPROMPT,rpromptfunc);
  } else {
    if(he->rpromptSv != NULL) {
      sv_free(he->rpromptSv);
      he->rpromptSv = NULL;
    }
    if(SvPOK(func)) {
      he->rprompt = malloc(SvLEN(func)+1);
      strcpy(he->rprompt,SvPV(func,PL_na));
    }
    RETVAL = el_set(he->el,EL_PROMPT,rpromptfunc);
  }
}

SV * el_get_prompt(he)
     HistEdit *he
CODE:
{
  if(he->promptSv != NULL)
    RETVAL = he->promptSv;
  else if(he->prompt != NULL)
    RETVAL = newSVpv(he->prompt,0);
  else 
    RETVAL = &PL_sv_undef;
}

SV * el_get_rprompt(he)
     HistEdit *he
CODE:
{
  if(he->rpromptSv != NULL)
    RETVAL = he->rpromptSv;
  else if(he->rprompt != NULL)
    RETVAL = newSVpv(he->rprompt,0);
  else 
    RETVAL = &PL_sv_undef;
}

void
el_set_editor(he,mode)
     HistEdit * he
     char *mode
CODE:
{
  if (!strcmp(mode,"vi") || !strcmp(mode,"emacs"))
    el_set(he->el,EL_EDITOR,mode);
}

char*
el_get_editor(he)
     HistEdit *he
PREINIT:
     char mode[6];
CODE:
{
  el_get(he->el,EL_EDITOR,mode);
  RETVAL = mode;
}

int el_add_fun (he,name,help,sub)
     HistEdit * he
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
    RETVAL = el_set(he->el,EL_ADDFN,name,help,uf_tbl[i].cwrapper);
  }
}


int
el_source(he, arg1)
	HistEdit * 	he
	const char *	arg1
CODE:
{
  el_source(he->el,arg1);
}
