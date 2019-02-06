
[![Travis-CI Build
Status](https://travis-ci.org/hrbrmstr/udpprobe.svg?branch=master)](https://travis-ci.org/hrbrmstr/udpprobe)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hrbrmstr/udpprobe?branch=master&svg=true)](https://ci.appveyor.com/project/hrbrmstr/udpprobe)
[![Coverage
Status](https://codecov.io/gh/hrbrmstr/udpprobe/branch/master/graph/badge.svg)](https://codecov.io/gh/hrbrmstr/udpprobe)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/udpprobe)](https://cran.r-project.org/package=udpprobe)

# udpprobe

Send User Datagram Protocol (‘UDP’) Probes and Receive Responses

## Description

Unfortunately (but understandably) R has no built in connection support
for the user datagram protocol (‘UDP’). We aim to somewhat fix that with
the ability to send a lightweight probe and receive lightweight
responses over ‘UDP’ to a target host/port. **Supports Windows, macOS
and Linux clients.**

## What’s Inside The Tin

*The following functions are implemented:*

The core probe function:

  - `udp_send_payload`: Send a UDP payload and return the response (if
    any)

Helpers for Ubiquity Discover Protocol probes

  - `ubnt_discovery_probe`: Send a Ubiquiti Discovery probe to a host
    with a discovery query payload and receive a response udpprobe Send
    UDP payloads and gather response
  - `parse_ubnt_discovery_response`: Parser for Ubiquiti Discovery
    Protocol responses

## Installation

``` r
devtools::install_git("https://git.sr.ht/~hrbrmstr/udpprobe")
# or
devtools::install_gitlab("hrbrmstr/udpprobe")
# or
devtools::install_github("hrbrmstr/udpprobe")
```

## Usage

``` r
library(udpprobe)

# current version
packageVersion("udpprobe")
## [1] '0.2.0'
```

## Fun with manually crafting DNS records

What’s the IP address of `example.com`?

``` r
c(
  0xaa, 0xaa, # id
  0x01, 0x00, # |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
  0x00, 0x01, # QDCOUNT num of questions
  0x00, 0x00, # ANCOUNT 0 since it's only for answers
  0x00, 0x00, # NSCOUNT 0 since it's only for answers
  0x00, 0x00, # ARCOUNT 0 sicne it's only for answers
  0x07,       # start of QNAME beginning with size of "example"
  0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65,  # example
  0x03,       # size of "com" (excluding null terminator)
  0x63, 0x6f, 0x6d, 0x00,  # "com" with null terminator
  0x00, 0x01, # QTYPE ("A" == 1)
  0x00, 0x01  # QCLASS (internet == 1)
) -> dns_req

(resp <- udp_send_payload("8.8.8.8", 53, dns_req))
##  [1] aa aa 81 80 00 01 00 01 00 00 00 00 07 65 78 61 6d 70
## [19] 6c 65 03 63 6f 6d 00 00 01 00 01 c0 0c 00 01 00 01 00
## [37] 00 24 ca 00 04 5d b8 d8 22

paste0(as.integer(tail(resp, 4)), collapse = ".")
## [1] "93.184.216.34"

curl::nslookup("example.com")
## [1] "93.184.216.34"
```

## Live Ubiquiti Test (internet host redacted)

``` r
# the following just does:
#   udp_send_payload(Sys.getenv("UBNT_TEST_HOST"), 10001L, c(0x01, 0x00, 0x00, 0x00))
(x <- ubnt_discovery_probe(Sys.getenv("UBNT_TEST_HOST")))
##   [1] 01 00 00 a0 02 00 0a dc 9f db 3a 5f 09 8a ff bd a9 02
##  [19] 00 0a dc 9f db 3b 5f 09 c0 a8 02 01 01 00 06 dc 9f db
##  [37] 3a 5f 09 0a 00 04 00 00 43 58 0b 00 15 39 36 39 20 2d
##  [55] 20 4a 75 76 65 6e 61 6c 20 52 69 62 65 69 72 6f 0c 00
##  [73] 03 4c 4d 35 0d 00 11 4e 45 54 53 55 50 45 52 2d 53 49
##  [91] 51 55 45 49 52 41 0e 00 01 02 03 00 22 58 4d 2e 61 72
## [109] 37 32 34 30 2e 76 35 2e 36 2e 35 2e 32 39 30 33 33 2e
## [127] 31 36 30 35 31 35 2e 32 31 31 39 10 00 02 e8 a5 14 00
## [145] 13 4e 61 6e 6f 53 74 61 74 69 6f 6e 20 4c 6f 63 6f 20
## [163] 4d 35

parse_ubnt_discovery_response(x)
## [Model: LM5; Firmware: XM.ar7240.v5.6.5.29033.160515.2119; Uptime: 0.2 (hrs)
```

## udpprobe Metrics

| Lang | \# Files | (%) | LoC | (%) | Blank lines | (%) | \# Lines | (%) |
| :--- | -------: | --: | --: | --: | ----------: | --: | -------: | --: |
| NA   |        0 |   0 |   0 |   0 |           0 |   0 |        0 |   0 |

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
