# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.4.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# 実行に必要なパッケージ
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    postgresql-client \
    libpq-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# ビルドステージ
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libyaml-dev \
    pkg-config \
    libpq-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .

# 実行用イメージ
FROM base

# railsユーザーを作成
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

# 必要なディレクトリを作成し権限を付与
RUN mkdir -p db log storage tmp
RUN chown -R rails:rails db log storage tmp

# ビルドステージから成果物をコピー
COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

USER 1000:1000

# 起動コマンド：
# 1. アセットプリコンパイル（起動時ならMASTER_KEYが読み込める）
# 2. DBマイグレーション
# 3. サーバー起動（Thruster経由。パスが通っていない場合を考慮してbundle execを使用）
CMD ["/bin/sh", "-c", "export RAILS_ENV=production && bundle exec rails assets:precompile && bundle exec rails db:migrate && ./bin/thrust ./bin/rails server"]