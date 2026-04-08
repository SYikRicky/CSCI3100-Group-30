FROM ruby:3.4.7

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y \
    nodejs \
    npm \
    sqlite3 \
    libsqlite3-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install gems first (cached layer)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy rest of the app
COPY . .

# Set up databases
RUN bin/rails db:prepare RAILS_ENV=development

EXPOSE 3000

CMD ["bin/dev"]