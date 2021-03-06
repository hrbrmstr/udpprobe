% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/echo.R
\name{udp_echo}
\alias{udp_echo}
\title{Send an echo request to an echo server}
\usage{
udp_echo(host, payload = "hello", port = 7L)
}
\arguments{
\item{host}{host or IP address of target}

\item{payload}{what you want echoed back! Defaults to "\code{hello}".}

\item{port}{defaults to \code{7L} (the standard \code{echo} port)}
}
\value{
character vector
}
\description{
Unfortunately, \code{echo} servers are not great things to be running on the public
internet but you can stand one up locally if you don't know how to find one
externally (as of 2019 there are ~300K ov them on the public internet).
}
\examples{
\dontrun{
udp_echo("91.207.125.246", "the message you want back")
}
}
\seealso{
Other insecure old internet service utility functions: \code{\link{udp_daytime}},
  \code{\link{udp_qotd}}
}
\concept{insecure old internet service utility functions}
