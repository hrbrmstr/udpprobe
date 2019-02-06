#ifdef WIN64
#define IS_WINDOWS
#elif defined WIN32
#define IS_WINDOWS
#endif

#ifdef IS_WINDOWS
#include <Rinternals.h>
#include <Rdefines.h>
#include <stdlib.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <winsock2.h>
#include <io.h>

#define BUFSIZE (1024*48)

SEXP R_udp_send_payload(SEXP host, SEXP port, SEXP payload, SEXP timeout, SEXP buf_size) {

  SOCKET sockfd;
  SOCKADDR_IN target_addr;
  WSADATA wsaData;

  int n, addr_size;

  int sz = REAL(buf_size)[0];
  unsigned char *resp = (unsigned char *)R_alloc(sz, sizeof(unsigned char));

  if (resp == NULL) error("No memory available for UDP receive buffer.");

  DWORD tv = REAL(timeout)[0] * 1000;

  WSAStartup(MAKEWORD(2, 2), &wsaData);

  sockfd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if (sockfd == SOCKET_ERROR) {
    Rf_warning("invalid socket: %d", sockfd);
    WSACleanup();
    return(R_NilValue);
  }

  if (setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, (const char *)&tv, sizeof(tv))) {
    Rf_warning("timeout setting failed: %d", WSAGetLastError());
    closesocket(sockfd);
    WSACleanup();
    return(R_NilValue);
  }

  addr_size = sizeof(target_addr);

  memset(&target_addr, 0, addr_size);
  target_addr.sin_family = AF_INET;
  target_addr.sin_addr.s_addr = inet_addr(CHAR(STRING_ELT(host, 0)));
  target_addr.sin_port = htons(INTEGER(port)[0]);

  n = sendto(sockfd, (const char *)RAW(payload), LENGTH(payload), 0, (struct sockaddr *)&target_addr, sizeof(target_addr));
  if (n < 0) {
    Rf_warning("sendto failed: %d", WSAGetLastError());
    closesocket(sockfd);
    WSACleanup();
    return(R_NilValue);
  }

  memset(resp, 0, sz);
  n = recvfrom(sockfd, (char *)resp, sz, 0, (struct sockaddr *)&target_addr, &addr_size);

  if (n < 0) {
    Rf_warning("receive failed: %d", WSAGetLastError());
    closesocket(sockfd);
    WSACleanup();
    return(R_NilValue);
  }

  closesocket(sockfd);
  WSACleanup();

  SEXP out = Rf_allocVector(RAWSXP, n);
  memcpy(RAW(out), resp, n);

  return(out);

}
#endif