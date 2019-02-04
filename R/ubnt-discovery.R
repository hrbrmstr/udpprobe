#' Send a Ubiquiti Discovery probe to a host with a discovery query payload and receive a response
#'
#' The `payload` is not fixed since it appears there may be other discovery
#' query payloads. Use [parse_ubnt_discovery_response()] to handle the the raw
#' result from this function.
#'
#' @md
#' @param host host or IP address of target
#' @param port defaults to `10001L` but folks may be running it on others
#' @param payload the discovery protocol query payload. The default is known to work.
#' @export
#' @return raw vector
#' @family Ubiquity Discovery Protocol functions
#' @examples \dontrun{
#' x <- ubnt_discovery_probe("some ip address or host name")
#' if (!is.null(x)) parse_ubnt_discovery_response(x)
#' }
ubnt_discovery_probe <- function(host, port = 10001L, payload = c(0x01, 0x00, 0x00, 0x00)) {
  udp_send_payload(host, as.integer(port), payload)
}

#' Parser for Ubiquiti Discovery Protocol responses
#'
#' Takes a raw or base64 encoded Ubiquity Discovery Protocol response and turns it into
#' a list.
#'
#' @md
#' @param a either a `raw` vector with the raw response byte data or a base64 encoded version of the same
#' @return an `ubi_d` classed `list`  with device `name`, `model_long` and `model_short` model info, `firmware` string
#'         station `esssid`, device `uptime` (if provided), device `macs` (MAC addresses) and
#'         `ips` (IPv4 addresses) and any unprocessed fields as named raw vectors (named by their field code).
#' @family Ubiquity Discovery Protocol functions
#' @export
#' @examples
#' paste0(
#'   c(
#'     "AQAAggIACiSkPH9XF8+QRUICAAokpDx+VxfAqAUBAQAGJKQ8flcXCgAEACylqg",
#'     "sADEFpclJvdXRlciBIUAwABkxBUC1IUA0AD1dDVGVsLVdpRmktNTcxNw4AAQMDA",
#'     "CJYTS5hcjcyNDAudjUuNS42LjE3NzYyLjEzMDUyOC4xNzU1EAAC5LI="
#'   ), collaspe = ""
#' ) -> base64_response
#'
#' parse_ubnt_discovery_response(base64_response)
#'
#' \dontrun{
#' x <- ubnt_discovery_probe("some ip address or host name")
#' if (!is.null(x)) parse_ubnt_discovery_response(x)
#' }
parse_ubnt_discovery_response <- function(a) {

  if (is.character(a)) a <- openssl::base64_decode(a)
  if (!is.raw(a)) return(NULL)

  if (!all(a[1:3] == c(0x01, 0x00, 0x00))) return(NULL)

  d <- list(
    name = character(0),
    model_long = character(0),
    model_short = character(0),
    firmware = character(0),
    essid = character(0),
    uptime = integer(0),
    macs = character(0),
    ips = character(0)
  )

  pos <- 5 # skip to the data

  repeat {

    field_type <- as.character(a[pos])
    field_len <- readBin(a[(pos+1):(pos+2)], "int", size=2, endian = "big")
    pos <- pos + 3

    if (field_len < 0) {
      warning("This appears to be a damaged response. Ignoring.", call. = FALSE)
      return(NULL)
    }

    if ((length(field_type)>0) && (field_len>0)) {
      switch(
        field_type,
        "01" = {
          d[["macs"]] <- c(d[["macs"]], paste0(as.character(a[pos:(pos+5)]), collapse=":")) # 6 bytes for MAC
        },
        "02" = {
          d[["macs"]] <- c(d[["macs"]], paste0(as.character(a[pos:(pos+5)]), collapse=":")) # 6 bytes for MAC
          d[["ips"]] <- c(d[["ips"]], paste0(as.integer(a[(pos+6):(pos+9)]), collapse=".")) # 4 byte IP address
        },
        "03" = {
          d[["firmware"]] <- readBin(a[pos:(pos+field_len-1)], "character") # field_len-length string (firmware info of device)
        },
        "0a" = {
          d[["uptime"]] <- readBin(a[pos:(pos+field_len-1)], "integer", size=4, endian = "big") # unsigned 32-bit integer uptime (seconds)
        },
        "0b" = {
          d[["name"]] <- readBin(a[pos:(pos+field_len-1)], "character") # field_len length-string (name of device)
        },
        "0c" = {
          d[["model_short"]] <- readBin(a[pos:(pos+field_len-1)], "character") # field_len-length string (short model name of device)
        },
        "0d" = {
          d[["essid"]] <- readBin(a[pos:(pos+field_len-1)], "character") # field_len-length string (essid of device)
        },
        "14" = {
          d[["model_long"]] <- readBin(a[pos:(pos+field_len-1)], "character") # field_len-length string (long model name of device)
        },
        # "known" unknown fields
        # "00"  field_len is usually 0 so this could be for padding but it's UDP so why?
        # "07" usually 1,408 bytes
        # "0e" usually 1 byte
        # "0f" usually 4 bytes
        # "10" usually 2 bytes
        # "16" tends to be 1,284 bytes of all 0x00's
        # "17" usually 4 byte but can be 0
        # "18" usually 1 byte
        # "2f" usually 8,192 bytes
        # "31" usually 13,056 bytes
        # "42" usually 16,707 bytes
        # "ec" usually 12,004 bytes but sometimes 2
        # "ff" usually 2 bytes
        d[[sprintf("ux%s", field_type)]] <- a[pos:(pos+field_len-1)] # unkown so raw
      )
    }

    pos <- pos + field_len
    if (pos > length(a)) break

  }

  if (length(d[["macs"]])) d[["macs"]] <- sort(unique(d[["macs"]]))
  if (length(d[["ips"]])) d[["ips"]] <- sort(unique(d[["ips"]]))

  class(d) <- c("ubnt_d")

  d

}

#' Printer for ubnt_d object
#'
#' @md
#' @param x ubnt_d object
#' @param ... ignored
#' @keywords internal
#' @export
print.ubnt_d <- function(x, ...) {

  mdl <- NULL
  if (length(x$model_short) > 0) {
    mdl <- sprintf("Model: %s", x$model_short)
  } else if (length(x$model_long) > 0) {
    mdl <- sprintf("Model: %s", x$model_long)
  }

  nm <- NULL
  if (length(x$name)) nm <- sprintf("Name: %s", x$name)

  fw <- NULL
  if (length(x$firmware)) nm <- sprintf("Firmware: %s", x$firmware)

  ut <- NULL
  if (length(x$uptime)) ut <- sprintf("Uptime: %s (hrs)", scales::comma_format(0.1)(x$uptime/60/60/24))

  cat("[", paste0(c(mdl, nm, fw, ut), collapse="; "), "\n", sep="")

}

