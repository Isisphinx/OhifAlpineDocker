FROM node:16.19.0-slim AS build

RUN apt-get update && apt-get install -y wget tar

RUN mkdir /build/ \ 
  && wget -qO- https://github.com/OHIF/Viewers/archive/refs/tags/@ohif/viewer@4.12.45.tar.gz | tar xvz --strip=1 -C /build/ 

WORKDIR /build/

RUN yarn config set workspaces-experimental true \
  && yarn install

RUN yarn run build

FROM nginx:1.23.3-alpine

RUN apk add --no-cache bash
RUN rm -rf /etc/nginx/conf.d
COPY --from=build /build/.docker/Viewer-v2.x /etc/nginx/conf.d
COPY --from=build /build/.docker/Viewer-v2.x/entrypoint.sh /usr/src/
RUN chmod 777 /usr/src/entrypoint.sh
COPY --from=build /build/platform/viewer/dist /usr/share/nginx/html
EXPOSE 80
EXPOSE 443
ENTRYPOINT ["/usr/src/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
