FROM ubuntu:18.04 AS builder

RUN apt-get update
RUN apt-get install -y bash curl git grep make

RUN mkdir /toolbox

WORKDIR /macrocode

# Actual analyzer build step
# All analyzers are expected to have a Makefile inside the .deepsource/analyzer directory in the repo
RUN cd /.deepsource/analyzer && make build

FROM us.gcr.io/deepsource-dev/marvin:debian

COPY --from=builder /app /app
COPY --from=builder /toolbox /toolbox

RUN ln -s /usr/local/bin/python3 /usr/bin/python3

RUN chmod -R o-rwx /code /toolbox
RUN chown -R 1000:3000 /toolbox /code
RUN adduser -u 1000 runner && \
	mkdir -p /home/runner && \
	chown -R 1000:3000 /home/runner

WORKDIR /app

USER 1000
