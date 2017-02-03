FROM ruby:2.2-alpine

ENV RAILS_ENV=production \
    HELPY_HOME=/helpy \
    HELPY_USER=helpyuser \
    HELPY_SLACK_INTEGRATION_ENABLED=true

WORKDIR $HELPY_HOME

# Install runtime dependencies and clone repo
RUN apk --update --no-cache add \
    git \
    imagemagick \
    nodejs \
    postgresql-client \
    tzdata \
  && adduser -S $HELPY_USER \
  && mkdir -p $HELPY_HOME \
  && git clone --depth=1 https://github.com/helpyio/helpy.git $HELPY_HOME \
  && apk del git

# Copy database config and run script into the container
COPY database.yml $HELPY_HOME/config/database.yml
COPY run.sh $HELPY_HOME/run.sh

# Modify Gemfile to remove the line which says 'ruby "2.2.1"' to use a newer ruby version
RUN sed -i '/ruby "2.2.1"/d' $HELPY_HOME/Gemfile

# Add NullDB to Gemfile to allow us to precompile assets at build time
RUN echo 'gem "activerecord-nulldb-adapter"' >> $HELPY_HOME/Gemfile

# Add the Slack integration gem to the Gemfile if the HELPY_SLACK_INTEGRATION_ENABLED is true
# Use `test` for sh compatibility, also use only one `=`. also for sh compatibility
RUN test "$HELPY_SLACK_INTEGRATION_ENABLED" = "true" && sed -i '$ a\gem "helpy_slack", git: "https://github.com/helpyio/helpy_slack.git", branch: "master"' $HELPY_HOME/Gemfile

# Install Ruby dependencies and precompile assets
RUN apk --update --no-cache add --virtual build-deps \
    g++ \
    git \
    linux-headers \
    make \
    musl-dev \
    postgresql-dev \
    sqlite-dev \
  && bundle install \
  && DB_ADAPTER=nulldb bundle exec rake assets:precompile \
  && apk del build-deps

# Due to a weird issue with one of the gems, execute this permissions change:
RUN chmod +r /usr/local/bundle/gems/griddler-mandrill-1.1.3/lib/griddler/mandrill/adapter.rb

# Link log files and set permissions
RUN ln -sf /dev/stdout /helpy/log/production.log \
  && chown -R $HELPY_USER $HELPY_HOME /usr/local/lib/ruby /usr/local/bundle \
  && chmod +x $HELPY_HOME/run.sh

USER $HELPY_USER

CMD ["./run.sh"]