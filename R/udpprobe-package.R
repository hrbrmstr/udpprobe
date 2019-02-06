#' Send UDP payloads and gather response
#'
#' Unfortunately (but understandably) R has no built in connection
#' support for the user datagram protocol ('UDP'). We aim to somewhat fix that
#' with the ability to send a lightweight probe and receive lightweight
#' responses over 'UDP' to a target host/port. Supports Windows, macOS and Linux
#' clients.
#'
#' - URL: <https://gitlab.com/hrbrmstr/udpprobe>
#' - BugReports: <https://gitlab.com/hrbrmstr/udpprobe/issues>
#'
#' @md
#' @name udpprobe
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @importFrom curl nslookup
#' @importFrom openssl base64_decode
#' @importFrom scales comma
#' @keywords internal
#' @useDynLib udpprobe, .registration=TRUE
NULL
