FROM ruby:3.3.7

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libyaml-dev \
  libpq-dev \
  pkg-config

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3001

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && rails s -b 0.0.0.0 -p 3001"]