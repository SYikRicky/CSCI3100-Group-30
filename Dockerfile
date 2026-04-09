FROM ruby:3.4.7

RUN apt-get update -qq && \
    apt-get install -y \
    nodejs \
    npm \
    sqlite3 \
    libsqlite3-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# Fix CRLF line endings on all bin/ scripts
RUN sed -i 's/\r//' bin/*

EXPOSE 3000

CMD ["bash", "-c", "bin/rails db:prepare && bin/dev"]