web: bundle exec puma -C config/puma.rb
release: bundle exec rails db:prepare && bundle exec rails db:schema:load:queue db:schema:load:cache db:schema:load:cable 2>/dev/null; true
