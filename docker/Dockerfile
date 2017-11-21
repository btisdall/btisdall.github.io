FROM ruby:2.4.2-alpine3.6

RUN apk add --update \
  build-base \
  ruby-dev \
  && adduser ruby -D -h /home/ruby \
  ;

COPY Gemfile /home/ruby/

WORKDIR /home/ruby

USER ruby

RUN bundle install
