
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

Helpers for Ubiquity Discover Protocol probes:

  - `ubnt_discovery_probe`: Send a Ubiquiti Discovery probe to a host
    with a discovery query payload and receive a response udpprobe Send
    UDP payloads and gather response
  - `parse_ubnt_discovery_response`: Parser for Ubiquiti Discovery
    Protocol responses

Helpers for old, insecure internet services:

  - `udp_daytime`: Send an request for the day/time
  - `udp_echo`: Send an echo request to an echo server
  - `udp_qotd`: Send an request for the QOTD

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
## [1] '0.2.1'
```

### Fun with manually crafting DNS records

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
## [37] 00 4b 0c 00 04 5d b8 d8 22

paste0(as.integer(tail(resp, 4)), collapse = ".")
## [1] "93.184.216.34"

curl::nslookup("example.com")
## [1] "93.184.216.34"
```

### Live Ubiquiti Test (internet host redacted)

``` r
# the following just does:
#   udp_send_payload(Sys.getenv("UBNT_TEST_HOST"), 10001L, c(0x01, 0x00, 0x00, 0x00))
(x <- ubnt_discovery_probe(Sys.getenv("UBNT_TEST_HOST")))
## NULL

parse_ubnt_discovery_response(x)
## NULL
```

### Old, indecure internet services:

``` r
cat(udp_echo("91.207.125.246", "the message you want back"), "\n")
## the message you want back

cat(udp_qotd("119.48.167.199"), "\n")
## "When a stupid man is doing something he is ashamed of, he always declares
##  that it is his duty." George Bernard Shaw (1856-1950)

cat(udp_daytime("195.34.89.241"), "\n")
## 06 FEB 2019 16:19:04 CET
## 
```

## udpprobe Metrics

| Lang       | \# Files |  (%) | LoC |  (%) | Blank lines |  (%) | \# Lines |  (%) |
| :--------- | -------: | ---: | --: | ---: | ----------: | ---: | -------: | ---: |
| C          |        3 | 0.27 | 147 | 0.44 |          41 | 0.34 |        4 | 0.02 |
| R          |        6 | 0.55 | 146 | 0.43 |          38 | 0.31 |      140 | 0.70 |
| Rmd        |        1 | 0.09 |  30 | 0.09 |          36 | 0.30 |       57 | 0.28 |
| Dockerfile |        1 | 0.09 |  14 | 0.04 |           7 | 0.06 |        0 | 0.00 |

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
