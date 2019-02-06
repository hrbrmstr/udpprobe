FROM rocker/r-devel-san

ENV UBSAN_OPTIONS print_stacktrace=1
ENV ASAN_OPTIONS malloc_context_size=10:fast_unwind_on_malloc=false

RUN apt-get -qq update \
	&& apt-get -qq dist-upgrade -y \
	&& apt-get -qq install git pandoc pandoc-citeproc libssl-dev libcurl4-openssl-dev -y \
  && RDscript -e 'install.packages(c("curl", "openssl", "scales"), dependencies = TRUE, quiet = TRUE)'

RUN git clone https://git.sr.ht/~hrbrmstr/udpprobe \
  && RD CMD build udpprobe --no-build-vignettes \
	&& RD CMD INSTALL udpprobe_*.tar.gz --install-tests

RUN RDscript -e 'sessionInfo()'

RUN RDscript -e 'library(udpprobe); testthat::test_dir("udpprobe/tests/testthat")' || true

RUN RDscript -e 'library(udpprobe); testthat::test_examples("udpprobe/man")'|| true

RUN RD CMD check udpprobe*.tar.gz
