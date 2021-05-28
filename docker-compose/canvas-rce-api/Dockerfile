FROM instructure/node-passenger:12

USER root
RUN npm install -g npm@6

USER docker
COPY . /usr/src/app

RUN npm install
