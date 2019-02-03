#' Send a UDP payload and return the response (if any)
#'
#' @note there's a hardcoded max response size of 4096 bytes for now #lazy
#' @param host host or ip address of target
#' @param port UDP port number
#' @param payload payload to send (raw bytes; [as.raw()] will be called if not)
#' @export
udp_send_payload <- function(host, port, payload) {

  host <- host[1]
  port <- as.integer(port[1])

  if (!is.raw(payload)) payload <- as.raw(payload)

  if (!grepl("^[[:digit:]\\.]$", host)) {
    host <- curl::nslookup(host, ipv4_only = TRUE, error = TRUE)
  }

  .Call("R_udp_send_payload", host = host, port = port, payload = payload)

}