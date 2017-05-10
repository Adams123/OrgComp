
#include <sys/timeb.h>
#ifdef DEBUG

static struct timeb __lasttime;
static struct timeb __thistime;
//extern struct timeb __lasttime;
//extern struct timeb __thistime;

#define debugfd stdout
//! Prints the time when this line was executed, if DEBUG is defined
#define DEBUG_TIME {ftime(&__thistime); __lasttime = __thistime; fprintf(debugfd, "%s:%d: time %ld %d\n", __FILE__, __LINE__, __thistime.time, __thistime.millitm);}

//! Prints how many milliseconds ellapsed between two executions of this macro, if DEBUG is defined
#define DEBUG_DIFF_TIME {__lasttime = __thistime; ftime(&__thistime); fprintf(debugfd, "%s:%d: elapsed time %ld miliseconds\n", __FILE__, __LINE__, (1000 * __thistime.time + __thistime.millitm) - (1000 * __lasttime.time + __lasttime.millitm));}

//! Executes the command x, if DEBUG is defined
#define DEBUG_EXEC(x) { DEBUG_PASS; x; }

//! Prints the filename and line of the command, if DEBUG is defined
#define DEBUG_PASS {fprintf(debugfd, "%s:%d\n", __FILE__, __LINE__);}

//! Checks whether the expresion x is true; if it is not, aborts the execution with segmentation fault. If DEBUG is not defined, does nothing.
#define DEBUG_ASSERT(x) {if (!(x)) {DEBUG_PASS; fprintf(debugfd, "assertion failed: %s\n", #x); *(int *)NULL = 0;}}

//! Prints the message x, if DEBUG is defined
#define DEBUG_WARNING(x) {fprintf(debugfd, x);}

//! Prints the contents of variable x, using printf format code f, if DEBUG is defined
#define DEBUG_INSPECT(x, f) {fprintf(debugfd, "%s:%d %s = " #f "\n", __FILE__, __LINE__, #x, x);}

#else

#define DEBUG_TIME
#define DEBUG_EXEC(x) 
#define DEBUG_PASS
#define DEBUG_ASSERT(x) ;
#define DEBUG_WARNING(x) 
#define DEBUG_INSPECT(x, f) ;


#endif
