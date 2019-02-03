#ifdef WIN64
#define IS_WINDOWS
#elif defined WIN32
#define IS_WINDOWS
#endif

#ifndef IS_WINDOWS
#include <Rinternals.h>
#include <Rdefines.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

SEXP R_udp_send_payload(SEXP host, SEXP port, SEXP payload) {

  int sockfd, n;
  socklen_t target_len;
  struct sockaddr_in target_addr;
  struct hostent *target;
  char resp[4096];

  sockfd = socket(AF_INET, SOCK_DGRAM, 0);
  if (sockfd < 0) return(R_NilValue);

  target = gethostbyname(CHAR(STRING_ELT(host, 0)));
  if (target == NULL) {
    close(sockfd);
    return(R_NilValue);
  }

  bzero((char *)&target_addr, sizeof(target_addr));
  target_addr.sin_family = AF_INET;
  bcopy(
    (char *)target->h_addr,
	  (char *)&target_addr.sin_addr.s_addr,
	  target->h_length
	 );
  target_addr.sin_port = htons(INTEGER(port)[0]);
  target_len = sizeof(target_addr);

  n = sendto(sockfd, RAW(payload), LENGTH(payload), 0, (const struct sockaddr *)&target_addr, target_len);
  if (n <  0) {
    close(sockfd);
    return(R_NilValue);
  }

  bzero(resp, 4096);
  n = recvfrom(sockfd, &resp, 4096, 0, (struct sockaddr *)&target_addr, &target_len);

  close(sockfd);

  if (n < 0) return(R_NilValue);

  SEXP out = Rf_allocVector(RAWSXP, n);
  memcpy(RAW(out), resp, n);

  return(out);

}
#endif