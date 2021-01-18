# syntax = docker/dockerfile:1.0-experimental
FROM node:14-alpine

RUN --mount=type=cache,target=/etc/apk/cache apk --update-cache add \
  shadow 

ARG UID=1000
RUN usermod -u $UID node

RUN chown node:node /opt

USER node
WORKDIR /opt

ENTRYPOINT ["/usr/local/bin/npm"]
CMD ["-help"]
