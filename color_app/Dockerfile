# syntax=docker/dockerfile:1
# check=error=true

# Rails 8 用に最適化された Render 向け Dockerfile
ARG RUBY_VERSION=3.4.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# アプリケーションの作業ディレクトリ
WORKDIR /rails

# 実行に必要な最小限のパッケージをインストール
# libpq-dev は PostgreSQL (pg gem) の実行に必要です
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    postgresql-client \
    libpq-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# 本番環境用の環境変数設定
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# ビルドステージ
FROM base AS build

# Gem のビルドに必要なパッケージをインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libyaml-dev \
    pkg-config \
    libpq-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Gem のインストール
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# アプリケーションコードのコピー
COPY . .

# アセットのプリコンパイル
# SECRET_KEY_BASE_DUMMY=1 に加え、DATABASE_URL をダミーに設定することで
# ビルド時の DB 接続エラーを完全に回避します
RUN RAILS_ENV=production \
    DATABASE_URL=postgresql://dummy:dummy@localhost/dummy \
    SECRET_KEY_BASE_DUMMY=1 \
    bundle exec rails assets:precompile

# 実行用イメージの作成
FROM base

# セキュリティのため一般ユーザーを作成して実行
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

# ビルドステージから必要なファイルをコピー
COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

# 起動時のエントリーポイント
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# ポート 80 を開放
EXPOSE 80

# Thruster を使用して Rails サーバーを起動
CMD ["./bin/thrust", "./bin/rails", "server"]