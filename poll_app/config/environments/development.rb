require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server.
  config.enable_reloading = true

  # Eager load code on boot. This will force your application to load all classes
  # so that modifications to code do not trigger a browser reload.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing.
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/dev_cache").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which time zone to use when setting Ruby's Time zone (default is :local).
  # config.active_support.default_time_zone = :local

  # 🚨 【修正】古いRailsバージョンでエラーになるため、この行をコメントアウトします 🚨
  # Raise exceptions for missing template and switch back to normal error handling if any exceptions are raised during symbol loading
  # config.action_view.raise_on_missing_names = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you are using a complicated setup that requires exposing the
  # Rails application to the outside world.
  # config.web_console.permissions = '10.0.0.0/8'

  # Suppress logger output for asset requests.
  config.assets.quiet = true
  
  # Importmapの問題を解決するためにアセットダイジェストを無効化します 
  config.assets.digest = false 

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # 古いRailsバージョンでエラーになるため、この設定をコメントアウトします 
  # config.action_controller.raise_on_unfiltered_parameters = true

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # スペルミス 'raiise' を 'raise' に修正 
  config.turbo.raise_on_navigate = true
end