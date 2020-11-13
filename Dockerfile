FROM golang:1.13.10
LABEL maintainer="Yulexi Matienzo <Github: @Ebioro>"

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt update && \
  apt -y install yarn

# set working dir
WORKDIR /go/src/github.com/stellar/kelp

ENV GOPATH /go
ENV GLIDE_PATH $GOPATH/src/github.com/Masterminds/glide
ENV ASTILELECTRON_PATH $GOPATH/src/github.com/asticode/go-astilectron-bundler
ENV KELP_PATH $GOPATH/src/github.com/stellar/kelp

# install kelp + glide
RUN git clone https://github.com/Masterminds/glide $GLIDE_PATH && \
  cd $GLIDE_PATH && \
  make build

# install kelp
RUN git clone https://github.com/Ebioro/stellar-kelp.git . && \
  mv $GLIDE_PATH/glide $KELP_PATH && \
  git fetch --tags && \
  ./glide install

# install astielectron
RUN git clone https://github.com/asticode/go-astilectron-bundler.git $ASTILELECTRON_PATH && \
  cd $ASTILELECTRON_PATH && \
  go install $ASTILELECTRON_PATH/astilectron-bundler

# needed libtool for sodium
RUN apt-get install -y autoconf automake g++ libtool

# run build script
RUN mv $ASTILELECTRON_PATH/astilectron-bundler $KELP_PATH && \
  ./scripts/build.sh

# set ulimit
RUN ulimit -n 10000

# use command line arguments from invocation of docker run against this ENTRYPOINT command - https://stackoverflow.com/a/40312311/1484710
ENTRYPOINT ["./bin/kelp"]