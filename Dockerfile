FROM ruby:3.4.3
WORKDIR /build
COPY Gemfile /build
COPY Gemfile.lock /build
RUN bundle install
COPY . /build
RUN bundle exec jekyll build
