/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 10 "expr.y"


#include <ctype.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <limits.h>

#define	LONGLEN	12		/* max length of NUL-terminated ASCII long */
#define	CODELEN	512		/* initial length of code buffer */
#define	CODEINC	128		/* code buffer length increment */

#define	EOF	(-1)
#define TRUE	(0 == 0)
#define FALSE	(0 != 0)
#define true(e)	(*(e) == '\0' || (isnum(e) && atol(e) == 0) ? FALSE : TRUE)

int	exstat;		/* exit status returned by main() */
char	*result;	/* final expr printed by main */
char	s0[] = "0";	/* `0' integer - `false' expr */
char	s1[] = "1";	/* `1' integer - `true' expr */

char *ltoascii(long n);
char *regexp(char *e1, char *e2);
char *arithop(int op, char *e1, char *e2);
char *relop(int op, char *e1, char *e2);
int isnum(char *e);
void compile(char *e);
char *match(char *lp, char *cp);
char *overflow(char *pc);
void output(char *s, int fildes);
int yylex(void);
void yyerror(const char *p);
void regerror(void);
void dieat (void);
void divzero(void);
void errexit(void);

/*
 * The following names are used by the regular expression operator.
 */
#define BRSIZE	10			/* Length of brace list */
typedef	struct {
	char	*b_bp;			/* Ptr to start of string matched */
	char	*b_ep;			/* Ptr to end of string matched */
} BRACE;

#define CSNUL	000			/* End of expression */
#define CSSOL	001			/* Match start of line */
#define CSEOL	002			/* End of line */
#define CSOPR	003			/* \( */
#define CSCPR	004			/* \) */
#define CSBRN	005			/* Match nth brace */
#define CSDOT	006			/* Any character */
#define CMDOT	007			/* Stream of any characters */
#define CSCHR	010			/* Match given character */
#define CMCHR	011			/* Match stream of given characters */
#define CSCCL	014			/* Character class */
#define CMCCL	015			/* Stream of character class */
#define CSNCL	016			/* Not character class */
#define CMNCL	017			/* Stream of not char class */

#define	getx(c)		*e++
#define ungetx(c)	--e

BRACE	brlist[BRSIZE];			/* brace list */
int	brcount;			/* # of braces in reg_expr */
char	*codebuf;			/* Ptr to a compiled regular expr */
int	cbsiz = CODELEN;			/* Initial size of codebuf */

#define YYSTYPE	char *

char	**av;		/* Global version of argv[] in main() */
int	avx;		/* Index into av[] */

#line 148 "expr.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif


/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    STR = 258,                     /* STR  */
    LE = 259,                      /* LE  */
    GE = 260,                      /* GE  */
    EQ = 261,                      /* EQ  */
    NEQ = 262,                     /* NEQ  */
    UMINUS = 263,                  /* UMINUS  */
    LEN = 264                      /* LEN  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif
/* Token kinds.  */
#define YYEMPTY -2
#define YYEOF 0
#define YYerror 256
#define YYUNDEF 257
#define STR 258
#define LE 259
#define GE 260
#define EQ 261
#define NEQ 262
#define UMINUS 263
#define LEN 264

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);



/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_STR = 3,                        /* STR  */
  YYSYMBOL_4_ = 4,                         /* '|'  */
  YYSYMBOL_5_ = 5,                         /* '&'  */
  YYSYMBOL_6_ = 6,                         /* '<'  */
  YYSYMBOL_7_ = 7,                         /* '>'  */
  YYSYMBOL_LE = 8,                         /* LE  */
  YYSYMBOL_GE = 9,                         /* GE  */
  YYSYMBOL_EQ = 10,                        /* EQ  */
  YYSYMBOL_NEQ = 11,                       /* NEQ  */
  YYSYMBOL_12_ = 12,                       /* '+'  */
  YYSYMBOL_13_ = 13,                       /* '-'  */
  YYSYMBOL_14_ = 14,                       /* '*'  */
  YYSYMBOL_15_ = 15,                       /* '/'  */
  YYSYMBOL_16_ = 16,                       /* '%'  */
  YYSYMBOL_17_ = 17,                       /* ':'  */
  YYSYMBOL_UMINUS = 18,                    /* UMINUS  */
  YYSYMBOL_19_ = 19,                       /* '!'  */
  YYSYMBOL_LEN = 20,                       /* LEN  */
  YYSYMBOL_21_ = 21,                       /* '('  */
  YYSYMBOL_22_ = 22,                       /* ')'  */
  YYSYMBOL_23_ = 23,                       /* '{'  */
  YYSYMBOL_24_ = 24,                       /* ','  */
  YYSYMBOL_25_ = 25,                       /* '}'  */
  YYSYMBOL_YYACCEPT = 26,                  /* $accept  */
  YYSYMBOL_start = 27,                     /* start  */
  YYSYMBOL_expr = 28                       /* expr  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;




#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_int8 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if !defined yyoverflow

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* !defined yyoverflow */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  15
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   172

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  26
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  3
/* YYNRULES -- Number of rules.  */
#define YYNRULES  24
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  51

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   264


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    19,     2,     2,     2,    16,     5,     2,
      21,    22,    14,    12,    24,    13,     2,    15,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    17,     2,
       6,     2,     7,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    23,     4,    25,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     8,
       9,    10,    11,    18,    20
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_uint8 yyrline[] =
{
       0,   109,   109,   113,   115,   116,   117,   126,   128,   129,
     130,   131,   132,   134,   135,   136,   137,   138,   139,   141,
     142,   144,   145,   147,   148
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if YYDEBUG || 0
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "\"end of file\"", "error", "\"invalid token\"", "STR", "'|'", "'&'",
  "'<'", "'>'", "LE", "GE", "EQ", "NEQ", "'+'", "'-'", "'*'", "'/'", "'%'",
  "':'", "UMINUS", "'!'", "LEN", "'('", "')'", "'{'", "','", "'}'",
  "$accept", "start", "expr", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-8)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-1)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
      26,    -8,    -8,    26,    26,    26,    26,    26,    11,   130,
      -8,    -8,    -8,   111,    90,    -8,    26,    26,    26,    26,
      26,    26,    26,    26,    26,    26,    26,    26,    26,    26,
      -8,    26,   143,   155,    -7,    -7,    -7,    -7,    -7,    -7,
      16,    16,    -5,    -5,    -5,    -8,    46,    26,    -8,    68,
      -8
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       0,    24,    23,     0,     0,     0,     0,     0,     0,     2,
       6,     5,     4,     0,     0,     1,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       3,     0,    20,    19,    13,    14,    15,    16,    17,    18,
      11,    12,     8,     9,    10,     7,     0,     0,    21,     0,
      22
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
      -8,    -8,    -3
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
       0,     8,     9
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int8 yytable[] =
{
      10,    11,    12,    13,    14,    24,    25,    26,    27,    28,
      29,    15,    29,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    41,    42,    43,    44,    45,     1,    46,     2,
      26,    27,    28,    29,     0,     0,     0,     0,     0,     3,
       0,     0,     0,     0,    49,     4,     5,     6,     0,     7,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,    27,    28,    29,     0,     0,     0,     0,     0,     0,
      47,    48,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,    28,    29,     0,     0,     0,     0,
       0,     0,     0,    50,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,     0,     0,
       0,     0,     0,     0,    31,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,     0,
       0,     0,     0,    30,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,    27,    28,
      29,    18,    19,    20,    21,    22,    23,    24,    25,    26,
      27,    28,    29
};

static const yytype_int8 yycheck[] =
{
       3,     4,     5,     6,     7,    12,    13,    14,    15,    16,
      17,     0,    17,    16,    17,    18,    19,    20,    21,    22,
      23,    24,    25,    26,    27,    28,    29,     1,    31,     3,
      14,    15,    16,    17,    -1,    -1,    -1,    -1,    -1,    13,
      -1,    -1,    -1,    -1,    47,    19,    20,    21,    -1,    23,
       4,     5,     6,     7,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    -1,    -1,    -1,    -1,    -1,    -1,
      24,    25,     4,     5,     6,     7,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    25,     4,     5,     6,     7,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    -1,    -1,
      -1,    -1,    -1,    -1,    24,     4,     5,     6,     7,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    -1,
      -1,    -1,    -1,    22,     4,     5,     6,     7,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,     5,     6,
       7,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,     1,     3,    13,    19,    20,    21,    23,    27,    28,
      28,    28,    28,    28,    28,     0,     4,     5,     6,     7,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      22,    24,    28,    28,    28,    28,    28,    28,    28,    28,
      28,    28,    28,    28,    28,    28,    28,    24,    25,    28,
      25
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr1[] =
{
       0,    26,    27,    28,    28,    28,    28,    28,    28,    28,
      28,    28,    28,    28,    28,    28,    28,    28,    28,    28,
      28,    28,    28,    28,    28
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     3,     2,     2,     2,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     5,     7,     1,     1
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)




# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp,
                 int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)]);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif






/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep)
{
  YY_USE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = YYEOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      goto yyerrlab1;
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 2: /* start: expr  */
#line 109 "expr.y"
                        { result = yyvsp[0]; exstat = true(result) ? 0 : 1; }
#line 1262 "expr.c"
    break;

  case 3: /* expr: '(' expr ')'  */
#line 113 "expr.y"
                        { yyval = yyvsp[-1]; }
#line 1268 "expr.c"
    break;

  case 4: /* expr: LEN expr  */
#line 115 "expr.y"
                        { yyval = ltoascii((long)strlen(yyvsp[0])); }
#line 1274 "expr.c"
    break;

  case 5: /* expr: '!' expr  */
#line 116 "expr.y"
                        { yyval = true(yyvsp[0]) ? s0 : s1; }
#line 1280 "expr.c"
    break;

  case 6: /* expr: '-' expr  */
#line 118 "expr.y"
                        { if (isnum(yyvsp[0]))
				yyval = ltoascii(-atol(yyvsp[0]));
			else {
				--avx;
				yyerror("");
			}
			}
#line 1292 "expr.c"
    break;

  case 7: /* expr: expr ':' expr  */
#line 126 "expr.y"
                        { yyval = regexp(yyvsp[-2], yyvsp[0]); }
#line 1298 "expr.c"
    break;

  case 8: /* expr: expr '*' expr  */
#line 128 "expr.y"
                        { yyval = arithop('*', yyvsp[-2], yyvsp[0]); }
#line 1304 "expr.c"
    break;

  case 9: /* expr: expr '/' expr  */
#line 129 "expr.y"
                        { yyval = arithop('/', yyvsp[-2], yyvsp[0]); }
#line 1310 "expr.c"
    break;

  case 10: /* expr: expr '%' expr  */
#line 130 "expr.y"
                        { yyval = arithop('%', yyvsp[-2], yyvsp[0]); }
#line 1316 "expr.c"
    break;

  case 11: /* expr: expr '+' expr  */
#line 131 "expr.y"
                        { yyval = arithop('+', yyvsp[-2], yyvsp[0]); }
#line 1322 "expr.c"
    break;

  case 12: /* expr: expr '-' expr  */
#line 132 "expr.y"
                        { yyval = arithop('-', yyvsp[-2], yyvsp[0]); }
#line 1328 "expr.c"
    break;

  case 13: /* expr: expr '<' expr  */
#line 134 "expr.y"
                        { yyval = relop('<', yyvsp[-2], yyvsp[0]); }
#line 1334 "expr.c"
    break;

  case 14: /* expr: expr '>' expr  */
#line 135 "expr.y"
                        { yyval = relop('>', yyvsp[-2], yyvsp[0]); }
#line 1340 "expr.c"
    break;

  case 15: /* expr: expr LE expr  */
#line 136 "expr.y"
                        { yyval = relop(LE, yyvsp[-2], yyvsp[0]); }
#line 1346 "expr.c"
    break;

  case 16: /* expr: expr GE expr  */
#line 137 "expr.y"
                        { yyval = relop(GE, yyvsp[-2], yyvsp[0]); }
#line 1352 "expr.c"
    break;

  case 17: /* expr: expr EQ expr  */
#line 138 "expr.y"
                        { yyval = relop(EQ, yyvsp[-2], yyvsp[0]); }
#line 1358 "expr.c"
    break;

  case 18: /* expr: expr NEQ expr  */
#line 139 "expr.y"
                        { yyval = relop(NEQ, yyvsp[-2], yyvsp[0]); }
#line 1364 "expr.c"
    break;

  case 19: /* expr: expr '&' expr  */
#line 141 "expr.y"
                        { yyval = true(yyvsp[0]) ? yyvsp[-2] : s0; }
#line 1370 "expr.c"
    break;

  case 20: /* expr: expr '|' expr  */
#line 142 "expr.y"
                        { yyval = true(yyvsp[-2]) ? yyvsp[-2] : yyvsp[0]; }
#line 1376 "expr.c"
    break;

  case 21: /* expr: '{' expr ',' expr '}'  */
#line 144 "expr.y"
                                        { yyval = true(yyvsp[-3]) ? yyvsp[-1] : s0; }
#line 1382 "expr.c"
    break;

  case 22: /* expr: '{' expr ',' expr ',' expr '}'  */
#line 145 "expr.y"
                                        { yyval = true(yyvsp[-5]) ? yyvsp[-3] : yyvsp[-1]; }
#line 1388 "expr.c"
    break;

  case 23: /* expr: STR  */
#line 147 "expr.y"
                        { yyval = yyvsp[0]; }
#line 1394 "expr.c"
    break;

  case 24: /* expr: error  */
#line 148 "expr.y"
                        { yyerror(""); }
#line 1400 "expr.c"
    break;


#line 1404 "expr.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      yyerror (YY_("syntax error"));
    }

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

#line 154 "expr.y"





int main(int argc, char *argv[])
{
	if (argc == 1)
		return 2;
	av = argv;
	yyparse();
	output(result, 1);
	output("\n", 1);
	return exstat;
}


char *arithop(int op, char *e1, char *e2)
{
	register long v1, v2;

	if (!isnum(e1)) {
		avx -= 3;
		yyerror("");
	}
	if (!isnum(e2)) {
		--avx;
		yyerror("");
	}

	v1 = atol(e1);
	v2 = atol(e2);
	switch (op) {
	case '+':
		v1 += v2;
		break;
	case '-':
		v1 -= v2;
		break;
	case '*':
		v1 *= v2;
		break;
	case '/':
		if (v2 == 0) {
			divzero ();
			v1 = LONG_MAX;
		} else
			v1 /= v2;
		break;
	case '%':
		if (v2 == 0) {
			divzero ();
			v1 = 0;
		} else
			v1 %= v2;
		break;
	}
	return ltoascii(v1);
}

char *relop(int op, char *e1, char *e2)
{
	register int cmp;
	register long v1, v2;

	if (!isnum(e1) || !isnum(e2))
		cmp = strcmp(e1, e2);
	else {
		v1 = atol(e1);
		v2 = atol(e2);
		cmp = (v1 > v2) ? 1 : (v1 == v2) ? 0 : -1;
	}
	switch (op) {
	case '<':
		return (cmp < 0) ? s1 : s0;
	case '>':
		return (cmp > 0) ? s1 : s0;
	case LE:
		return (cmp <= 0) ? s1 : s0;
	case GE:
		return (cmp >= 0) ? s1 : s0;
	case EQ:
		return (cmp == 0) ? s1 : s0;
	case NEQ:
		return (cmp != 0) ? s1 : s0;
	}
}


char *regexp(char *e1, char *e2)
{
	register char *a = e1;
	register char *b;
	register BRACE *brp;

	codebuf = malloc(CODELEN);
	compile(e2);
	if (brcount > 0)	/* brcount is now the number of braces in e2 */
		brlist[brcount].b_bp = brlist[brcount].b_ep = NULL;
#if	1
	/* Posix P1003.2 4.22.7.1: pattern search is anchored to beginning. */
	b = match(a, codebuf);
#else
	/* This code searches for unanchored match. */
	if (codebuf[0] == CSSOL)
		b = match(a, codebuf + 1);
	else
		for ( ; *a != '\0'; ++a)
			if ((b = match(a, codebuf)) != NULL)
				break;
#endif
	if (b == NULL)
#if	1
		/* If \(\) used, string-valued return */
		return brcount == 0 ? "0" : "";
#else
		return "0";
#endif
	if (brcount == 0)
		return ltoascii((long)(b - a));

	/* Remaining case is extraction of fields */
	for (a = e1, brp = brlist; (b = brp->b_bp) != NULL; ++brp)
		while (b < brp->b_ep)
			*a++ = *b++;
	*a = '\0';
	free (codebuf);
	return e1;
}


int isnum(char *e)
{
	register int c;

	if ((c = * e ++) == '-')	/* || c == '+' Removed for POSIX */
		c = * e ++;
	do
		if (! isdigit (c))
			return FALSE;
	while ((c = * e ++) != 0);
	return TRUE;
}

/*
 * Convert long to ascii. Return pointer to the necessary malloced storage.
 */
char *ltoascii(long n)
{
	char buf[LONGLEN];
	register char *bp = buf;
	register char *ep;
	register char *e;

	e = ep = malloc(LONGLEN);
	if (n < 0) {
		*ep++ = '-';
		n = -n;
	}
	do {
		*bp++ = (n % 10) + '0';
		n /= 10;
	} while (n > 0);
	while (bp > buf)
		*ep++ = *--bp;
	*ep = '\0';
	return e;
}


/*
 * Compile the regular expression e into codebuf.
 * Invoke regerror() on a regular expression syntax error.
 */
void compile(char *e)
{
	register int c;
	register char *cp, *lcp;
	int blevel, n, notflag, bstack[BRSIZE + 1];

	brcount = 0;
	blevel = 0;
	cp = &codebuf[0];
	if ((c = getx(c)) == '^') {
		*cp++ = CSSOL;
		c = getx(c);
	}
	while (c != '\0') {
		if (cp > &codebuf[cbsiz-4])
			cp = overflow(cp);
		switch (c) {
		case '*':
			regerror();
		case '.':
			if ((c = getx(c)) != '*') {
				*cp++ = CSDOT;
				continue;
			}
			*cp++ = CMDOT;
			c = getx(c);
			continue;
		case '$':
			if ((c = getx(c)) != '\0') {
				ungetx(c);
				c = '$';
				goto character;
			}
			*cp++ = CSEOL;
			continue;
		case '[':
			/*
			 * lcp[0] will contain C<S|M><C|N>CL. lcp[1] will be
			 * the number of chars in the class. These are followed
			 * by the members of the class singly enumerated.
			 * ']' is valid only at the start of the member list.
			 * '-' is valid only at the end of the member list.
			 */
			lcp = cp;
			if ((c = getx(c)) == '^')
				notflag = TRUE;
			else {
				notflag = FALSE;
				ungetx(c);
			}
			cp += 2;
			if ((c = getx(c)) == ']')
				*cp++ = c;
			else
				ungetx(c);
			while ((c = getx(c)) != ']') {
				if (c == '\0')
					regerror();
				if (c!='-' || cp==lcp+2) {
					if (cp >= &codebuf[cbsiz-4])
						cp = overflow(cp);
					*cp++ = c;
					continue;
				}

				/* c = '-' now. Lookahead at the next char */
				if ((c = getx(c)) == '\0')
					regerror();
				if (c == ']') {
					*cp++ = '-';
					ungetx(c);
					continue;
				}
				if ((n=cp[-1]) > c)
					regerror();
				while (++n <= c) {
					if (cp >= &codebuf[cbsiz-4])
						cp = overflow(cp);
					*cp++ = n;
				}
			}
			if ((c = getx(c)) == '*') {
				lcp[0] = (notflag) ? CMNCL : CMCCL;
				c = getx(c);
			}
			else
				lcp[0] = (notflag) ? CSNCL : CSCCL;
			if ((n=cp-(lcp+2)) > 255)
				regerror();
			*++lcp = n;
			continue;
		case '\\':
			switch (c = getx(c)) {
			case '\0':
				regerror();
			case '(':
				*cp++ = CSOPR;
				*cp++ = bstack[blevel++] = brcount++;
				c = getx(c);
				continue;
			case ')':
				if (blevel == 0)
					regerror();
				*cp++ = CSCPR;
				*cp++ = bstack[--blevel];
				c = getx(c);
				continue;
			default:
				if (isascii(c) && isdigit(c)) {
					*cp++ = CSBRN;
					*cp++ = c-'0' - 1;
					c = getx(c);
					continue;
				}
			}
		default:
		character:
			*cp++ = CSCHR;
			*cp++ = c;
			if ((c = getx(c)) == '*') {
				cp[-2] = CMCHR;
				c = getx(c);
			}
		}
	}
	*cp++ = CSNUL;
	return;
}

/*
 * Given a pointer to a compiled expression `cp' and a pointer to a line `lp',
 * return a ptr to the char following the last char of the match
 * if successful, NULL otherwise.
 */
char *match(char *lp, char *cp)
{
	register int n;
	char *llp, *lcp;

	for (;;) {
		switch (*cp++) {
		case CSNUL:
			return lp;
		case CSEOL:
			if (*lp)
				return NULL;
			return lp;
		case CSOPR:
			brlist[*cp++].b_bp = lp;
			continue;
		case CSCPR:
			brlist[*cp++].b_ep = lp;
			continue;
		case CSBRN:
			n = *cp++;
			lcp = cp;
			cp = brlist[n].b_bp;
			n = brlist[n].b_ep - cp;
			if (n > strlen(lp))
				return NULL;
			while (n-- > 0)
				if (*lp++ != *cp++)
					return NULL;
			cp = lcp;
			continue;
		case CSDOT:
			if (*lp++ == '\0')
				return NULL;
			continue;
		case CMDOT:
			llp = lp;
			while (*lp)
				lp++;
			goto star;
		case CSCHR:
			if (*cp++ != *lp++)
				return NULL;
			continue;
		case CMCHR:
			llp = lp;
			while (*cp == *lp)
				lp++;
			cp++;
			goto star;
		case CSCCL:
			n = *cp++;
			while (*cp++ != *lp)
				if (--n == 0)
					return NULL;
			lp++;
			cp += n-1;
			continue;
		case CMCCL:
			llp = lp;
			lcp = cp;
			while (*lp) {
				cp = lcp;
				n = *cp++;
				while (*cp++ != *lp)
					if (--n == 0)
						goto star;
				lp++;
			}
			cp = lcp + *lcp + 1;
			goto star;
		case CSNCL:
			if (*lp == '\0')
				return NULL;
			n = *cp++;
			while (n--)
				if (*cp++ == *lp)
					return NULL;
			lp++;
			continue;
		case CMNCL:
			llp = lp;
			lcp = cp;
			while (*lp) {
				cp = lcp;
				n = *cp++;
				while (n--) {
					if (*cp++ == *lp) {
						cp = lcp + *lcp + 1;
						goto star;
					}
				}
				lp++;
			}
			cp = lcp + *lcp + 1;
		star:
			do {
				if ((lcp = match(lp, cp)) != 0)
					return lcp;
			} while (--lp >= llp);
			return NULL;
		}
	}
}

/*
 * overflow enlarges codebuf by CODEINC bytes. The argument is a pointer
 * to a position in codebuf - the function returns a pointer with the same
 * relative position in the new buffer.
 */
char *overflow(char *pc)
{
	register int posn = pc - codebuf;

	if ((codebuf = realloc(codebuf, cbsiz += CODEINC)) == NULL)
		regerror();
	return codebuf + posn;
}

/*
 * An output function to avoid having to include stdio.
 */
void output(char *s, int fildes)
{
	register int len;

	len = strlen(s);
	if ((write(fildes, s, len)) != len)
		exit(3);
}


int yylex(void)
{
	register int c;

	if ((yylval = av[++avx]) == NULL)
		return EOF;
	if (av[avx][1] == '\0')
		switch (c = av[avx][0]) {
		case '{':
		case '}':
		case ',':
		case '|':
		case '&':
		case '<':
		case '>':
		case '+':
		case '-':
		case '*':
		case '/':
		case '%':
		case ':':
		case '!':
		case '(':
		case ')':
			return c;
		default:
			return STR;
		}
	if (av[avx][1] == '='  &&  av[avx][2] == '\0')
		switch (c = av[avx][0]) {
		case '<':
			return LE;
		case '>':
			return GE;
		case '=':
			return EQ;
		case '!':
			return NEQ;
		default:
			return STR;
		}
	return (strcmp(yylval, "len") == 0) ? LEN : STR;
}

/*
 * The common code between yyerror() and regerror() (in regexp.c) is split
 * off into errexit().
 */
void yyerror(const char *p)
{
	output("expr: ", 2);
	errexit();
}

void regerror(void)
{
	output("expr: regular expression ", 2);
	--avx;
	errexit();
}

void dieat (void)
{
	output(ltoascii((long) avx), 2);
	output("\n", 2);
	exit(2);
}

void divzero(void)
{
	output ("Attempt to divide by zero at argument # ", 2);
	-- avx;
	dieat ();
}

void errexit(void)
{
	output("syntax error at argument # ", 2);
	dieat ();
}

/* end of cmd/expr.y */
