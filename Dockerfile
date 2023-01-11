FROM node:19-alpine3.17 AS builder

RUN apk add git

RUN git clone https://github.com/OHIF/Viewers.git
RUN yarn config set workspaces-experimental true \
  && yarn install \
  && yarn run build

CMD sleep 3600