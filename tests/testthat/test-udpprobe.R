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

context("packets move")

resp <- udp_send_payload("8.8.8.8", 53, dns_req)

expect_equal(
  paste0(as.integer(tail(resp, 4)), collapse = "."),
  curl::nslookup("example.com")
)

context("timeout works")

testthat::expect_warning(
  udp_send_payload("8.4.1.3", 55, dns_req, timeout=0.1)
)

context("echo works")
expect_equal(
  udp_echo("91.207.125.246", "the message you want back"),
  "the message you want back"
)

context("qotd works")
expect_is(udp_qotd("119.48.167.199"), "character")

context("daytime works")
expect_is(udp_daytime("195.34.89.241"), "character")
