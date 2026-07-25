FROM debian:bullseye

RUN apt-get update && apt-get install -y g++ make git && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
RUN git clone https://github.com/ilorez/webserv.git
WORKDIR /usr/src/app/webserv
COPY ./tools/index.html ./www/index.html
RUN make
RUN mkdir -p ./config
COPY ./conf/webserv.conf ./config/webserv.conf

ENTRYPOINT ["/usr/src/app/webserv/webserv", "/usr/src/app/webserv/config/webserv.conf"]