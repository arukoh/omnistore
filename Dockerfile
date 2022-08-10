FROM ruby:3-alpine3.16

ENV RUNTIME_PACKAGES "git libxml2-dev libxslt-dev"
ENV DEV_PACKAGES "build-base"

RUN apk add --update --no-cache $RUNTIME_PACKAGES
RUN apk add --update --virtual build-dependencies --no-cache $DEV_PACKAGES
RUN gem install bundler nokogiri -N
RUN gem install json -N -v 1.8.6
RUN bundle config build.nokogiri --use-system-libraries

WORKDIR /usr/src/omnistore
ADD . .
# RUN bundle i
# RUN apk del build-dependencies
