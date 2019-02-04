#' Send a UDP payload and return the response (if any)
#'
#' @note there's a hardcoded max response size of 4096 bytes for now #lazy
#' @param host host or ip address of target
#' @param port UDP port number
#' @param payload payload to send (raw bytes; [as.raw()] will be called if not)
#' @param timeout UDP socket transmission/reception timeout (seconds); Default is 5s.
#' @param max_response_size maximum size of response to accept (bytes). Default if 4096
#' @export
udp_send_payload <- function(host, port, payload, timeout = 5, max_response_size = 4096) {

  host <- host[1]
  port <- as.integer(port[1])
  max_response_size <- as.numeric(max_response_size)

  if (!is.raw(payload)) payload <- as.raw(payload)

  if (!grepl("^[[:digit:]\\.]$", host)) {
    host <- curl::nslookup(host, ipv4_only = TRUE, error = TRUE)
  }

  .Call(
    "R_udp_send_payload",
    host = host,
    port = port,
    payload = payload,
    timeout = timeout,
    tbuf_size = max_response_size
  )

}