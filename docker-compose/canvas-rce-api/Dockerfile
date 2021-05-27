FROM instructure/node-passenger:10

USER root
RUN npm install -g npm@6

USER docker
COPY . /usr/src/app

RUN npm install
