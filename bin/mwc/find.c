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
#line 1 "find.y"

/*
 * Find all files in the given
 * directory hierarchies that
 * satisfy the given expression
 * primaries.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <dirent.h>
#include <err.h>
#include <grp.h>
#include <pwd.h>
#include "findnode.h"

#define DIRSIZ	30		/* FIXME */

#define	NPRIM	(sizeof(primaries)/sizeof(primaries[0]))
#define	NARG	50
#define	NRECUR	14		/* Maximum recursion depth before forking */
#define	NFNAME	600		/* size of filename buffer */
#define	FILEARG	((char *)EOF)
#define	DAYSEC	(60L*60L*24L)	/* seconds in a day */
#define	inode(f,v)	lnode(FUN,f,v,NULL)
#define	snode(f,s)	lnode(FUN,f,0,s)

#define YYSTYPE	NODE *

NODE	*code;
int	seflag;			/* Set if a side effect (print, exec) found */

char	*next(void);
NODE	*bnode(int, NODE *, NODE *);
NODE	*enode(int type);
NODE	*lnode(int op, int (*fn)(NODE *), int val, char *str);
NODE	*nnode(int (*fun)(NODE *));
NODE	*onode(int (*fun)(NODE *));
NODE	*getuser(void);
NODE	*getgroup(void);
NODE	*getnewer(void);
int	xname(NODE *np);
int	xperm(NODE *np);
int	xtype(NODE *np);
int	xlinks(NODE *np);
int	xuser(NODE *np);
int	xgroup(NODE *np);
int	xsize(NODE *np);
int	xinum(NODE *np);
int	xatime(NODE *np);
int	xctime(NODE *np);
int	xmtime(NODE *np);
int	xnewer(NODE *np);
int	xexec(NODE *np);
int	xprint(NODE *np);
int	xnop(NODE *np);

#line 132 "find.c"

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
    OR = 258,                      /* OR  */
    AND = 259,                     /* AND  */
    NAME = 260,                    /* NAME  */
    PERM = 261,                    /* PERM  */
    TYPE = 262,                    /* TYPE  */
    LINKS = 263,                   /* LINKS  */
    USER = 264,                    /* USER  */
    GROUP = 265,                   /* GROUP  */
    SIZE = 266,                    /* SIZE  */
    INUM = 267,                    /* INUM  */
    ATIME = 268,                   /* ATIME  */
    CTIME = 269,                   /* CTIME  */
    MTIME = 270,                   /* MTIME  */
    EXEC = 271,                    /* EXEC  */
    OK = 272,                      /* OK  */
    PRINT = 273,                   /* PRINT  */
    NEWER = 274,                   /* NEWER  */
    FUN = 275,                     /* FUN  */
    NOP = 276                      /* NOP  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif
/* Token kinds.  */
#define YYEMPTY -2
#define YYEOF 0
#define YYerror 256
#define YYUNDEF 257
#define OR 258
#define AND 259
#define NAME 260
#define PERM 261
#define TYPE 262
#define LINKS 263
#define USER 264
#define GROUP 265
#define SIZE 266
#define INUM 267
#define ATIME 268
#define CTIME 269
#define MTIME 270
#define EXEC 271
#define OK 272
#define PRINT 273
#define NEWER 274
#define FUN 275
#define NOP 276

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
  YYSYMBOL_OR = 3,                         /* OR  */
  YYSYMBOL_AND = 4,                        /* AND  */
  YYSYMBOL_5_ = 5,                         /* '!'  */
  YYSYMBOL_NAME = 6,                       /* NAME  */
  YYSYMBOL_PERM = 7,                       /* PERM  */
  YYSYMBOL_TYPE = 8,                       /* TYPE  */
  YYSYMBOL_LINKS = 9,                      /* LINKS  */
  YYSYMBOL_USER = 10,                      /* USER  */
  YYSYMBOL_GROUP = 11,                     /* GROUP  */
  YYSYMBOL_SIZE = 12,                      /* SIZE  */
  YYSYMBOL_INUM = 13,                      /* INUM  */
  YYSYMBOL_ATIME = 14,                     /* ATIME  */
  YYSYMBOL_CTIME = 15,                     /* CTIME  */
  YYSYMBOL_MTIME = 16,                     /* MTIME  */
  YYSYMBOL_EXEC = 17,                      /* EXEC  */
  YYSYMBOL_OK = 18,                        /* OK  */
  YYSYMBOL_PRINT = 19,                     /* PRINT  */
  YYSYMBOL_NEWER = 20,                     /* NEWER  */
  YYSYMBOL_FUN = 21,                       /* FUN  */
  YYSYMBOL_NOP = 22,                       /* NOP  */
  YYSYMBOL_23_n_ = 23,                     /* '\n'  */
  YYSYMBOL_24_ = 24,                       /* '('  */
  YYSYMBOL_25_ = 25,                       /* ')'  */
  YYSYMBOL_YYACCEPT = 26,                  /* $accept  */
  YYSYMBOL_command = 27,                   /* command  */
  YYSYMBOL_exp = 28                        /* exp  */
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
#define YYFINAL  24
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   66

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  26
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  3
/* YYNRULES -- Number of rules.  */
#define YYNRULES  23
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  31

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   276


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
      23,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     5,     2,     2,     2,     2,     2,     2,
      24,    25,     2,     2,     2,     2,     2,     2,     2,     2,
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
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       6,     7,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int8 yyrline[] =
{
       0,    73,    73,    78,    82,    83,    84,    85,    86,    87,
      88,    89,    90,    91,    92,    93,    94,    95,    96,    97,
      98,    99,   100,   101
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
  "\"end of file\"", "error", "\"invalid token\"", "OR", "AND", "'!'",
  "NAME", "PERM", "TYPE", "LINKS", "USER", "GROUP", "SIZE", "INUM",
  "ATIME", "CTIME", "MTIME", "EXEC", "OK", "PRINT", "NEWER", "FUN", "NOP",
  "'\\n'", "'('", "')'", "$accept", "command", "exp", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-3)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-1)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int8 yypact[] =
{
      22,    42,    -3,    -3,    -3,    -3,    -3,    -3,    -3,    -3,
      -3,    -3,    -3,    -3,    -3,    -3,    -3,    -3,    -3,    42,
       4,     3,    -3,    -2,    -3,    42,    42,    -3,    -3,     1,
      -3
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       0,     0,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,     3,     0,
       0,     0,     5,     0,     1,     0,     0,     2,     4,     6,
       7
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
      -3,    -3,    -1
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
       0,    20,    21
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int8 yytable[] =
{
      22,    25,    26,     0,    24,    26,    25,    26,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    23,     0,
       0,     0,     0,    28,    29,    30,    27,     1,     2,     3,
       4,     5,     6,     7,     8,     9,    10,    11,    12,    13,
      14,    15,    16,     0,    17,    18,    19,     1,     2,     3,
       4,     5,     6,     7,     8,     9,    10,    11,    12,    13,
      14,    15,    16,     0,    17,     0,    19
};

static const yytype_int8 yycheck[] =
{
       1,     3,     4,    -1,     0,     4,     3,     4,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    19,    -1,
      -1,    -1,    -1,    25,    25,    26,    23,     5,     6,     7,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    -1,    22,    23,    24,     5,     6,     7,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    -1,    22,    -1,    24
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,     5,     6,     7,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    22,    23,    24,
      27,    28,    28,    28,     0,     3,     4,    23,    25,    28,
      28
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr1[] =
{
       0,    26,    27,    27,    28,    28,    28,    28,    28,    28,
      28,    28,    28,    28,    28,    28,    28,    28,    28,    28,
      28,    28,    28,    28
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     2,     1,     3,     2,     3,     3,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1
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
  case 2: /* command: exp '\n'  */
#line 73 "find.y"
                                { if (seflag)
					code = yyvsp[-1]; else
					code = bnode(AND,yyvsp[-1],snode(xprint,NULL));
				  return 0;
				}
#line 1247 "find.c"
    break;

  case 3: /* command: '\n'  */
#line 78 "find.y"
                                { code = snode(xprint, NULL); return 0; }
#line 1253 "find.c"
    break;

  case 4: /* exp: '(' exp ')'  */
#line 82 "find.y"
                                { yyval = yyvsp[-1]; }
#line 1259 "find.c"
    break;

  case 5: /* exp: '!' exp  */
#line 83 "find.y"
                                { yyval = bnode('!', yyvsp[0], NULL); }
#line 1265 "find.c"
    break;

  case 6: /* exp: exp OR exp  */
#line 84 "find.y"
                                { yyval = bnode(OR, yyvsp[-2], yyvsp[0]); }
#line 1271 "find.c"
    break;

  case 7: /* exp: exp AND exp  */
#line 85 "find.y"
                                { yyval = bnode(AND, yyvsp[-2], yyvsp[0]); }
#line 1277 "find.c"
    break;

  case 8: /* exp: NAME  */
#line 86 "find.y"
                                { yyval = snode(xname, next()); }
#line 1283 "find.c"
    break;

  case 9: /* exp: PERM  */
#line 87 "find.y"
                                { yyval = onode(xperm); }
#line 1289 "find.c"
    break;

  case 10: /* exp: TYPE  */
#line 88 "find.y"
                                { yyval = snode(xtype, next()); }
#line 1295 "find.c"
    break;

  case 11: /* exp: LINKS  */
#line 89 "find.y"
                                { yyval = nnode(xlinks); }
#line 1301 "find.c"
    break;

  case 12: /* exp: USER  */
#line 90 "find.y"
                                { yyval = getuser(); }
#line 1307 "find.c"
    break;

  case 13: /* exp: GROUP  */
#line 91 "find.y"
                                { yyval = getgroup(); }
#line 1313 "find.c"
    break;

  case 14: /* exp: SIZE  */
#line 92 "find.y"
                                { yyval = nnode(xsize); }
#line 1319 "find.c"
    break;

  case 15: /* exp: INUM  */
#line 93 "find.y"
                                { yyval = nnode(xinum); }
#line 1325 "find.c"
    break;

  case 16: /* exp: ATIME  */
#line 94 "find.y"
                                { yyval = nnode(xatime); }
#line 1331 "find.c"
    break;

  case 17: /* exp: CTIME  */
#line 95 "find.y"
                                { yyval = nnode(xctime); }
#line 1337 "find.c"
    break;

  case 18: /* exp: MTIME  */
#line 96 "find.y"
                                { yyval = nnode(xmtime); }
#line 1343 "find.c"
    break;

  case 19: /* exp: EXEC  */
#line 97 "find.y"
                                { yyval = enode(0); }
#line 1349 "find.c"
    break;

  case 20: /* exp: OK  */
#line 98 "find.y"
                                { yyval = enode(1); }
#line 1355 "find.c"
    break;

  case 21: /* exp: PRINT  */
#line 99 "find.y"
                                { yyval = snode(xprint, NULL); seflag++; }
#line 1361 "find.c"
    break;

  case 22: /* exp: NEWER  */
#line 100 "find.y"
                                { yyval = getnewer(); }
#line 1367 "find.c"
    break;

  case 23: /* exp: NOP  */
#line 101 "find.y"
                                { yyval = snode(xnop, NULL); seflag++; }
#line 1373 "find.c"
    break;


#line 1377 "find.c"

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

#line 104 "find.y"

struct	primary	{
	char	*p_name;
	int	p_lval;
}	primaries[] = {
	{ "-name", NAME },
	{ "-perm", PERM },
	{ "-type", TYPE },
	{ "-links", LINKS },
	{ "-user", USER },
	{ "-group", GROUP },
	{ "-size", SIZE },
	{ "-inum", INUM },
	{ "-atime", ATIME },
	{ "-ctime", CTIME },
	{ "-mtime", MTIME },
	{ "-exec", EXEC },
	{ "-ok", OK },
	{ "-print", PRINT },
	{ "-newer", NEWER }, 
	{ "-nop", NOP },
	{ "-o", OR },
	{ "-a", AND },
};

char	**gav;
int	gac;
int	depth;			/* Recursive depth */

struct	stat	sb;
char	fname[NFNAME];
const char *prompt;

char	toodeep[] = "directory structure too deep to traverse";
char	nospace[] = "out of memory";

time_t	curtime;

char	*buildname(struct dirent *dp, char *ep);
int	execute(NODE *np);
void	find(char *dir);
void	fentry(char *ep, struct stat *sbp);
void	ffork(char *ep, struct stat *sbp);
void	usage(void);

int main(int argc, char *argv[])
{
	register int i;
	register char *ap;
	register int eargc;

	for (i=1; i<argc; i++) {
		ap = argv[i];
		if (*ap == '-')
			break;
		if (ap[1]=='\0' && (*ap=='!' || *ap=='('))
			break;
	}
	if ((eargc=i) < 2)
		usage();
	gav = argv+i;
	gac = argc-i;
	yyparse();
	time(&curtime);
	if ((prompt = getenv("PS1")) == NULL)
		prompt = "> ";
	for (i=1; i<eargc; i++)
		find(argv[i]);
}

/*
 * Lexical analyser
 */
int yylex(void)
{
	static int binop = 0;
	static int ntoken = 0;
	register char *ap;
	struct primary *pp;
	register int token;

	if (ntoken) {
		token = ntoken;
		ntoken = 0;
	} else if ((ap = next()) == NULL)
		token = '\n';
	else if (ap[1] == '\0')
		token = ap[0];
	else if (*ap == '-') {
		for (pp = primaries; pp <= &primaries[NPRIM-1]; pp++)
			if (strcmp(pp->p_name, ap) == 0) {
				token = pp->p_lval;
				break;
			}
		if (pp > &primaries[NPRIM-1])
			errx(1, "`%s' is an illegal primary", ap);
	} else
		errx(1, "Illegal expression %s\n", ap);
	if (binop && token!=')' && token!='\n' && token!=OR && token!=AND) {
		binop = 0;
		ntoken = token;
		return (AND);
	}
	if (token!=OR && token!=AND && token!='!' && token!='\n' && token!='(')
		binop = 1; else
		binop = 0;
	return (token);
}

void yyerror(const char *p)
{
	fprintf(stderr, "Primary expression syntax error\n");
	usage();
}

/*
 * Return the next argument from the arg list.
 */
char *next(void)
{
	if (gac < 1)
		return (NULL);
	gac--;
	return (*gav++);
}

/*
 * Produce a node consisting
 * of an octal number.
 */
NODE *onode(int (*fun)(NODE *))
{
	register char *ap;
	register int num;
	register NODE *np;
	register int type;
	char *aap;

	if ((ap = next()) == NULL)
		errx(1, "Missing octal permission");
	aap = ap;
	if (*ap == '-') {
		ap++;
		type = -1;
	} else
		type = 0;
	num = 0;
	while (*ap>='0' && *ap<='7')
		num = num*8 + *ap++-'0';
	if (*ap != '\0')
		errx(1, "%s: bad octal permission", aap);
	np = inode(fun, num);
	np->n_un.n_val = num;
	np->n_type = type;
	return (np);
}

/*
 * Get a number -- it also may be
 * prefixed by `+' or `-' to
 * represent quantities greater or
 * less.
 */
NODE *nnode(int (*fun)(NODE *))
{
	register char *ap;
	register int num = 0;
	register int type = 0;
	register NODE *np;
	char *aap;

	if ((ap = next()) == NULL)
		errx(1, "Missing number");
	aap = ap;
	if (*ap == '+') {
		type = 1;
		ap++;
	} else if (*ap == '-') {
		type = -1;
		ap++;
	}
	while (*ap>='0' && *ap<='9')
		num = num*10 + *ap++ - '0';
	if (*ap != '\0')
		errx(1, "%s: invalid number", aap);
	np = inode(fun, num);
	np->n_type = type;
	return (np);
}

/*
 * Get a user name or number.
 */
NODE *getuser(void)
{
	register struct passwd *pwp;
	register char *cp;
	register int uid;

	if ((cp = next()) == NULL)
		errx(1, "Missing username");
	if (*cp>='0' && *cp<='9')
		uid = atoi(cp);
	else {
		if ((pwp = getpwnam(cp)) == NULL)
			errx(1, "%s: bad user name", cp);
		uid = pwp->pw_uid;
	}
	return (lnode(FUN, xuser, uid, NULL));
}

/*
 * Get group
 */
NODE *getgroup(void)
{
	register struct group *grp;
	register char *cp;
	register int gid;

	if ((cp = next()) == NULL)
		errx(1, "Missing group name");
	if (*cp>='0' && *cp<='9')
		gid = atoi(cp);
	else {
		if ((grp = getgrnam(cp)) == NULL)
			errx(1, "%s: bad group name", cp);
		gid = grp->gr_gid;
	}
	return (lnode(FUN, xgroup, gid, NULL));
}

/*
 * Get the time for the file used in
 * the `-newer' primary.
 */
NODE *getnewer(void)
{
	register NODE *np;
	register char *fn;

	if ((fn = next()) == NULL)
		errx(1, "Missing filename for `-newer'");
	if (stat(fn, &sb) < 0)
		errx(1, "%s: nonexistent", fn);
	np = inode(xnewer, 0);
	np->n_un.n_time = sb.st_mtime;
	return (np);
}

/*
 * Build an expression tree node (non-leaf).
 */
NODE *bnode(int op, NODE *left, NODE *right)
{
	register NODE *np;

	if ((np = malloc(sizeof (NODE))) == NULL)
		errx(1, nospace);
	np->n_op = op;
	np->n_left = left;
	np->n_right = right;
	np->n_un.n_val = 0;
	return (np);
}

/*
 * Build a leaf node in expression tree.
 */
NODE *lnode(int op, int (*fn)(NODE *), int val, char *str)
{
	register NODE *np;

	if ((np = malloc(sizeof (NODE))) == NULL)
		errx(1, nospace);
	np->n_left = np->n_right = NULL;
	np->n_op = op;
	np->n_fun = fn;
	if (str != NULL)
		np->n_un.n_str = str;
	else
		np->n_un.n_val = val;
	return (np);
}

/*
 * Build an execution node
 * for -ok or -exec.
 */
NODE *enode(int type)
{
	register NODE *np;
	register char **app;
	register char *ap;

	seflag++;
	np = snode(xexec, NULL);
	np->n_type = type;
	if ((np->n_un.n_strp = (char**)malloc(sizeof(char*[NARG])))==NULL)
		errx(1, nospace);
	app = np->n_un.n_strp;
	for (;;) {
		if ((ap = next()) == NULL)
			errx(1, "Non-terminated -exec or -ok command list");
		if (strcmp(ap, "{}") == 0)
			ap = FILEARG;
		else if (strcmp(ap, ";") == 0)
			break;
		if (app-np->n_un.n_strp >= NARG-1)
			errx(1, "Too many -exec or -ok command arguments");
		*app++ = ap;
	}
	*app = NULL;
	return (np);
}

/*
 * Execute find on a single
 * pathname hierarchy.
 */

void find(char *dir)
{
	register char *ep, *cp;

	cp = dir;
	ep = fname;
	while (*cp)
		*ep++ = *cp++;
	*ep = '\0';
	if (stat(dir, &sb) < 0)
		err(1, "Cannot find directory `%s'", dir);
	if ((sb.st_mode&S_IFMT) != S_IFDIR)
		errx(1, "%s: not a directory", dir);
	fentry(ep, &sb);
}

/*
 * The pointer is the end pointer
 * into the fname buffer.
 * And the stat buffer is passed to this
 * which traverses the directory hierarchy.
 */
void fentry(char *ep, struct stat *sbp)
{
	register char *np;
	struct dirent *dp;
	DIR *dir;
	register int nb;
	int fd;
	int dirflag;
	char *iobuf;

	if (sbp != NULL) {
		dirflag = (sbp->st_mode&S_IFMT)==S_IFDIR;
		execute(code);
	} else
		dirflag = 1;
	if (dirflag) {
		if (++depth >= NRECUR) {
			depth = 0;
			ffork(ep, sbp);
			return;
		}
		if ((dir = opendir(fname)) == NULL) {
			warn("%s: cannot open directory", fname);
			return;
		}
		while ((dp = readdir(dir)) != NULL) {
			if (dp->d_ino == 0)
				continue;
			np = dp->d_name;
			if (*np++=='.'
			  && (*np=='\0' || (*np++=='.' && *np=='\0')))
				continue;
			np = buildname(dp, ep);
			if (stat(fname, &sb) < 0) {
				warn("%s: cannot stat", fname);
				continue;
			}
			fentry(np, &sb);
		}
		*ep = '\0';
		closedir(dir);
		depth--;
	}
}

/*
 * Fork to do a find on recursive directory
 * structure that is too deep to fit into
 * user's open files.
 */
void ffork(char *ep, struct stat *sbp)
{
	register int i;
	register int pid;
	int status;
	int nfile = sysconf(_SC_OPEN_MAX);

	fflush(stdout);
	if ((pid = fork()) < 0) {
		warn(toodeep);
		return;
	}
	if (pid) {
		while (wait(&status) >= 0)
			;
		if (status)
			warn("panic: child failed: %o", status);
		return;
	}
	for (i=3; i<nfile; i++)
		close(i);
	fentry(ep, (struct stat *)NULL);
	fflush(stdout);
	exit(0);
}

/*
 * Build up the next entry
 * in the name.
 */
char *buildname(struct dirent *dp, char *ep)
{
	register char *cp = dp->d_name;
	register unsigned n = DIRSIZ;

	if (ep+DIRSIZ+2 > &fname[NFNAME-1]) {
		warn(toodeep);
		return (NULL);
	}
	if (ep>fname && ep[-1]!='/')
		*ep++ = '/';
	do {
		if (*cp == '\0')
			break;
		*ep++ = *cp++;
	} while (--n);
	*ep = '\0';
	return (ep);
}

/*
 * Execute compiled code.
 */
int execute(NODE *np)
{
	switch (np->n_op) {
	case AND:
		if (execute(np->n_left) && execute(np->n_right))
			return (1);
		return (0);

	case OR:
		if (execute(np->n_left) || execute(np->n_right))
			return (1);
		return (0);

	case '!':
		return (!execute(np->n_left));

	case FUN:
		return ((*np->n_fun)(np));

	default:
		errx(1, "Panic: bad expression tree (op %d)", np->n_op);
	}
	/* NOTREACHED */
}

/* 
 * pnmatch(string, pattern, unanchored)
 * returns 1 if pattern matches in string.
 * pattern:
 *	[c1c2...cn-cm]	class of characters.
 *	?		any character.
 *	*		any # of any character.
 *	^		beginning of string (if unanchored)
 *	$		end of string (if unanchored)
 * unanch:
 *	0		normal (anchored) pattern.
 *	1		unanchored (^$ also metacharacters)
 *	>1		end unanchored.
 * >1 is used internally but should not be used by the user.
 */

int pnmatch(const char *s, const char *p, int unanch)
{
	int c1;
	int c2;

	if (unanch == 1) {
		while (*s)
			if (pnmatch(s++, p, ++unanch))
				return (1);
		return (0);
	}
	while (c2 = *p++) {
		c1 = *s++;
		switch(c2) {
		case '^':
			if (unanch == 2) {
				s--;
				continue;
			} else if (unanch == 0)
				break;
			else
				return (0);

		case '$':
			if (unanch)
				return (c1 == '\0');
			break;

		case '[':
			for (;;) {
				c2 = *p++;
				if (c2=='\0' || c2==']')
					return (0);
				if (c2 == '\\' && *p == '-') 
					c2 = *p++;
				if (c2 == c1)
					break;
				if (*p == '-')
					if (c1<=*++p && c1>=c2)
						break;
			}
			while (*p && *p++!=']')
				;

		case '?':
			if (c1)
				continue;
			return(0);

		case '*':
			if (!*p)
				return(1);
			s--;
			do {
				if (pnmatch(s, p, unanch))
					return (1);
			} while(*s++ != '\0');
			return(0);

		case '\\':
			if ((c2 = *p++) == '\0')
				return (0);
		}
		if (c1 != c2)
			return (0);
	}
	return(unanch ? 1 : !*s);
}

/*
 * Check for a match on the filename
 */
int xname(NODE *np)
{
	register char *ep;

	ep = fname;
	while (*ep != '\0')
		ep++;
	while (ep>fname && *--ep!='/')
		;
	if (*ep == '/')
		ep++;
	return (pnmatch(ep, np->n_un.n_str, 0));
}

/*
 * Compare the mode for a match again
 * octal number `np->n_un.n_val'.
 */
int xperm(NODE *np)
{
	register int onum;
	register int mode;

	mode = np->n_type<0 ? sb.st_mode&017777 : sb.st_mode&0777;
	onum = np->n_un.n_val;
	if (np->n_type < 0)
		return ((mode&onum) == onum);
	return (mode == onum);
}

/*
 * Compare again filetypes
 */
int xtype(NODE *np)
{
	register char *type;
	register int ftype;

	type = np->n_un.n_str;
	ftype = sb.st_mode&S_IFMT;
	if (type[1] == '\0')
		switch (type[0]) {
		case 'b':
			return (ftype == S_IFBLK);
	
		case 'c':
			return (ftype == S_IFCHR);
	
		case 'd':
			return (ftype == S_IFDIR);
	
		case 'f':
			return (ftype == S_IFREG);

#ifdef S_IFMPB	
		case 'm':
			return (ftype==S_IFMPB || ftype==S_IFMPC);
#endif			
		case 'p':
			return (ftype == S_IFIFO);
		}
	errx(1, "Bad file type `%s'", type);
}

/*
 * Numerical compare.
 */
int ncomp(NODE *np, unsigned int val)
{
	if (np->n_type == 0)
		return (np->n_un.n_val == val);
	if (np->n_type > 0)
		return (val > np->n_un.n_val);
	return (val < np->n_un.n_val);
}
/*
 * Compare link counts.
 */
int xlinks(NODE *np)
{
	return (ncomp(np, sb.st_nlink));
}

/*
 * Compare uid.
 */
int xuser(NODE *np)
{
	return (np->n_un.n_val == sb.st_uid);
}

/*
 * Compare group id of file
 * with given one.
 */
int xgroup(NODE *np)
{
	return (np->n_un.n_val == sb.st_gid);
}

/*
 * Compare size of file in blocks
 * with given.
 */
int xsize(NODE *np)
{
	register int fsize;

	fsize = (sb.st_size+BUFSIZ-1)/BUFSIZ;
	return (ncomp(np, fsize));
}

/*
 * Compare the i-number of the file
 * with that given.
 */
int xinum(NODE *np)
{
	return (ncomp(np, sb.st_ino));
}

/*
 * Do a numerical comparison on dates.
 */
int ndays(NODE *np, time_t t)
{
	register int days;

	days = (curtime-t+DAYSEC/2)/DAYSEC;
	return (ncomp(np, days));
}


/*
 * Return true if file has been accessed
 * in `n' days.
 */
int xatime(NODE *np)
{
	return (ndays(np, sb.st_atime));
}

/*
 * Return non-zero if file has been created
 * in `n' days.
 */
int xctime(NODE *np)
{
	return (ndays(np, sb.st_ctime));
}

/*
 * Return true if file has been modified
 * in `n' days.
 */
int xmtime(NODE *np)
{
	return (ndays(np, sb.st_mtime));
}

/*
 * Execute a command based on the filename
 */
int xexec(NODE *np)
{
	static char command[200];
	register char *ap, **app;
	register int c;
	int ok;

	command[0] = '\0';
	app = np->n_un.n_strp;
	while (*app != NULL) {
		if ((ap = *app++) == FILEARG)
			ap = fname;
		strcat(command, ap);
		if (*app != NULL)
			strcat(command, " ");
	}
	if (np->n_type) {
		printf("%s%s? ", prompt, command);
		ok = (c = getchar()) == 'y';
		while (c!='\n' && c!=EOF)
			c = getchar();
		if (!ok)
			return (0);
	}
	return (!system(command));
}

/*
 * Print the filename.
 */
/* ARGSUSED */
int xprint(NODE *np)
{
	printf("%s\n", fname);
	return (1);
}

int xnop(NODE *np)
{
	return (1);
}

/*
 * Return true if the file is newer than
 * the given one.
 */
int xnewer(NODE *np)
{
	return (sb.st_mtime > np->n_un.n_time);
}

void usage(void)
{
	fprintf(stderr, "Usage: find directory ... [ expression ]\n");
}
