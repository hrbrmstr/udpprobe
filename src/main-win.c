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

SEXP R_udp_send_payload(SEXP host, SEXP port, SEXP payload) {

  SOCKET sockfd;
  SOCKADDR_IN target_addr;
  WSADATA wsaData;

  char resp[4096];
  int n, addr_size;

  WSAStartup(MAKEWORD(2, 2), &wsaData);

  sockfd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if (sockfd == SOCKET_ERROR) {
    Rf_warning("invalid socket: %d", sockfd);
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

  memset(&resp, 0, 4096);
  n = recvfrom(sockfd, (char *)&resp, 4096, 0, (struct sockaddr *)&target_addr, &addr_size);

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