#' Send an echo request to an echo server
#'
#' Unfortunately, `echo` servers are not great things to be running on the public
#' internet but you can stand one up locally if you don't know how to find one
#' externally (as of 2019 there are ~300K ov them on the public internet).
#'
#' @md
#' @param host host or IP address of target
#' @param payload what you want echoed back! Defaults to "`hello`".
#' @param port defaults to `7L` (the standard `echo` port)
#' @export
#' @family insecure old internet service utility functions
#' @return character vector
#' @examples \dontrun{
#' udp_echo("91.207.125.246", "the message you want back")
#' }
udp_echo <- function(host,  payload = "hello", port = 7L) {
  if (is.character(payload)) payload <- charToRaw(payload)
  res <- udp_send_payload(host, as.integer(port), payload, timeout = 5)
  readBin(res, "character") # in case there are nulls
}

#' Send an request for the QOTD
#'
#' Quote of the Day servers are also rly bad things to put
#' on the public internet but there are over 40K of them as
#' of 2019. Find an IP and make a query!
#'
#' @md
#' @param host host or IP address of target
#' @param port defaults to `17L` (the standard `echo` port)
#' @export
#' @family insecure old internet service utility functions
#' @return character vector
#' @examples \dontrun{
#' udp_qotd("119.48.167.199")
#' }
udp_qotd<- function(host,  port = 17L) {
  res <- udp_send_payload(host, as.integer(port), as.raw(0x00), timeout = 5)
  readBin(res, "character") # in case there are nulls
}

#' Send an request for the day/time
#'
#' `daytime` servers are also rly bad things to put
#' on the public internet but there are a few, still, of them as
#' of 2019. Find an IP and make a query!
#'
#' @md
#' @param host host or IP address of target
#' @param port defaults to `13L` (the standard `echo` port)
#' @export
#' @family insecure old internet service utility functions
#' @return character vector
#' @examples \dontrun{
#' udp_daytime("195.34.89.241")
#' }
udp_daytime<- function(host, port = 13L) {
  res <- udp_send_payload(host, as.integer(port), charToRaw("\n"), timeout = 5)
  readBin(res, "character") # in case there are nulls
}
