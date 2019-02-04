#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME:
 Check these declarations against the C/Fortran source code.
 */

/* .Call calls */
extern SEXP R_udp_send_payload();

static const R_CallMethodDef CallEntries[] = {
  {"R_udp_send_payload", (DL_FUNC) &R_udp_send_payload, 5},
  {NULL, NULL, 0}
};

void R_init_wsock(DllInfo *dll)
{
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}