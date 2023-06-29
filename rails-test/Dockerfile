FROM ruby:3.2.2

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.4.14
RUN bundle install

COPY . .

RUN rake assets:precompile

EXPOSE 3030

CMD make serve
