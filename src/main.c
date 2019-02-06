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

SEXP R_udp_send_payload(SEXP host, SEXP port, SEXP payload, SEXP timeout, SEXP buf_size) {

  int sockfd, n;
  socklen_t target_len;
  struct sockaddr_in target_addr;
  struct hostent *target;

  int sz = REAL(buf_size)[0];
  unsigned char *resp = (unsigned char *)R_alloc(sz, sizeof(unsigned char));

  if (resp == NULL) error("No memory available for UDP receive buffer.");

  struct timeval tv;
  float secs = REAL(timeout)[0];
  tv.tv_sec = (int)secs;
  tv.tv_usec = (secs - (int)secs) * 1000000;

  sockfd = socket(AF_INET, SOCK_DGRAM, 0);
  if (sockfd < 0) return(R_NilValue);

  if (setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) < 0) {
    Rf_warning("timeout setting failed");
    close(sockfd);
    return(R_NilValue);
  }

  target = gethostbyname(CHAR(STRING_ELT(host, 0)));
  if (target == NULL) {
    Rf_warning("gethostbyname failed");
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
    Rf_warning("socket sending failed");
    close(sockfd);
    return(R_NilValue);
  }

  bzero(resp, sz);
  n = recvfrom(sockfd, resp, sz, 0, (struct sockaddr *)&target_addr, &target_len);

  close(sockfd);

  if (n < 0) {
    Rf_warning("socket receiving failed");
    return(R_NilValue);
  }

  SEXP out = Rf_allocVector(RAWSXP, n);
  memcpy(RAW(out), resp, n);

  return(out);

}
#endif