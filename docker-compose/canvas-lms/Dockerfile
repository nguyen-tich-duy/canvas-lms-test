# GENERATED FILE, DO NOT MODIFY!
# To update this file please edit the relevant template and run the generation
# task `build/dockerfile_writer.rb --env development --compose-file docker-compose.yml,docker-compose.override.yml --in build/Dockerfile.template --out Dockerfile`

ARG RUBY=2.6-p6.0.4
ARG POSTGRES_CLIENT=12

FROM instructure/ruby-passenger:$RUBY AS builder
LABEL maintainer="Instructure"

ARG POSTGRES_CLIENT
ENV APP_HOME /usr/src/app/
ENV RAILS_ENV production
ENV NGINX_MAX_UPLOAD_SIZE 10g
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ARG CANVAS_RAILS6_0=1
ENV CANVAS_RAILS6_0=${CANVAS_RAILS6_0}

ENV YARN_VERSION 1.19.1-1
ENV BUNDLER_VERSION 2.2.11
ENV GEM_HOME /home/docker/.gem/$RUBY
ENV PATH $GEM_HOME/bin:$PATH
ENV BUNDLE_APP_CONFIG /home/docker/.bundle

WORKDIR $APP_HOME

USER root

ARG USER_ID
# This step allows docker to write files to a host-mounted volume with the correct user permissions.
# Without it, some linux distributions are unable to write at all to the host mounted volume.
RUN if [ -n "$USER_ID" ]; then usermod -u "${USER_ID}" docker \
        && chown --from=9999 docker /usr/src/nginx /usr/src/app -R; fi

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
  && printf 'path-exclude /usr/share/doc/*\npath-exclude /usr/share/man/*' > /etc/dpkg/dpkg.cfg.d/01_nodoc \
  && echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && apt-get update -qq \
  && apt-get install -qqy --no-install-recommends \
       nodejs \
       yarn="$YARN_VERSION" \
       libxmlsec1-dev \
       python-lxml \
       libicu-dev \
       parallel \
       postgresql-client-$POSTGRES_CLIENT \
       unzip \
       pbzip2 \
       fontforge \
       autoconf \
       automake \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /home/docker/.gem/ruby/$RUBY_MAJOR.0

# install pulsar stuff
ENV PULSAR_VERSION=2.6.1
ENV PULSAR_CLIENT_SHA512=90fdb6e3ad85c9204f2b20a9077684f667f84be32df0952f8823ccee501c9d64a4c8131cab38a295a4cb66e2b63211afcc24f32130ded47e9da8f334ec6053f5
ENV PULSAR_CLIENT_DEV_SHA512=d0cc58c0032cb35d4325769ab35018b5ed823bc9294d75edfb56e62a96861be4194d6546107af0d5f541a778cdc26274aac9cb7b5ced110521467f89696b2209
# pulsar installs 4 versions of this library, but we only need
# one, so at the end we remove the others to minimize the image size
RUN cd "$(mktemp -d)" && \
    curl -SLO 'http://archive.apache.org/dist/pulsar/pulsar-'$PULSAR_VERSION'/DEB/apache-pulsar-client.deb' && \
    curl -SLO 'http://archive.apache.org/dist/pulsar/pulsar-'$PULSAR_VERSION'/DEB/apache-pulsar-client-dev.deb' && \
    echo $PULSAR_CLIENT_SHA512 '*apache-pulsar-client.deb' | shasum -a 512 -c -s - && \
    echo $PULSAR_CLIENT_DEV_SHA512 '*apache-pulsar-client-dev.deb' | shasum -a 512 -c -s - && \
    apt install ./apache-pulsar-client*.deb && \
    rm ./apache-pulsar-client*.deb && \
    rm /usr/lib/libpulsarnossl.so* && \
    rm /usr/lib/libpulsar.a && \
    rm /usr/lib/libpulsarwithdeps.a

RUN if [ -e /var/lib/gems/$RUBY_MAJOR.0/gems/bundler-* ]; then BUNDLER_INSTALL="-i /var/lib/gems/$RUBY_MAJOR.0"; fi \
  && gem uninstall --all --ignore-dependencies --force $BUNDLER_INSTALL bundler \
  && gem install bundler --no-document -v $BUNDLER_VERSION \
  && find $GEM_HOME ! -user docker | xargs chown docker:docker
RUN npm install -g npm@latest && npm cache clean --force

USER docker

COPY --chown=docker:docker . ${APP_HOME}

USER docker
# if yarn hits a snag try one more time with concurrency set to 1
# https://github.com/yarnpkg/yarn/issues/2629
RUN bundle install --jobs 8 \
  && (yarn install --pure-lockfile || yarn install --pure-lockfile --network-concurrency 1) \
  && mkdir -p .yardoc \
             app/stylesheets/brandable_css_brands \
             app/views/info \
             client_apps/canvas_quizzes/dist \
             client_apps/canvas_quizzes/node_modules \
             client_apps/canvas_quizzes/tmp \
             config/locales/generated \
             gems/canvas_i18nliner/node_modules \
             gems/selinimum/node_modules \
             log \
             node_modules \
             packages/canvas-planner/lib \
             packages/canvas-planner/node_modules \
             pacts \
             public/dist \
             public/doc/api \
             public/javascripts/client_apps \
             public/javascripts/compiled \
             public/javascripts/translations \
             reports \
             upload \
             tmp \
             /home/docker/.bundler/ \
             /home/docker/.cache/yarn \
             /home/docker/.gem/ \
  \
  && chmod +x vendor/QTIMigrationTool/migrate.py \
  # update Gemfile.lock in cases where a lock file was pulled in during the `COPY --chown=docker:docker . $APP_HOME` step \
  && bundle lock --local --conservative \
  \
  # TODO: switch to canvas:compile_assets_dev once we stop using this Dockerfile in production/e2e \
  && COMPILE_ASSETS_NPM_INSTALL=0 bundle exec rake canvas:compile_assets \
  # downgrade to prod dependencies \
  && bundle config set --local without 'test development mysql sqlite' \
  && bundle install \
  && bundle clean --force \
  \
  # now some cleanup... \
  && rm -rf \
    /home/docker/.bundle/cache \
    $GEM_HOME/cache \
    $GEM_HOME/bundler/gems/*/{.git,spec,test,features} \
    $GEM_HOME/gems/*/{spec,test,features} \
    `yarn cache dir` \
    /tmp/phantomjs \
    .yardoc \
    client_apps/canvas_quizzes/{tmp,node_modules} \
    config/locales/generated \
    gems/*/node_modules \
    gems/plugins/*/node_modules \
    public/dist/maps \
    public/doc/api/*.json \
    public/javascripts/translations \
    tmp-*.tmp \
    node_modules
