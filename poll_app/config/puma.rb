# This configuration file will be evaluated by Puma.
# For more information, see https://puma.io/puma/Puma/DSL.html.

# --- 1. THREADS (Concurrency within each worker process) ---
# The thread pool size. This is set higher than the default (3) for better throughput.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# --- 2. WORKERS (Concurrency across CPU cores) ---
# Specifies the number of worker processes to boot. 
# This is crucial for performance in production to use all available CPU cores.
# Default to 4 workers, or use the WEB_CONCURRENCY environment variable.
workers ENV.fetch("WEB_CONCURRENCY") { 4 }

# Use 'preload_app!' when using workers. It saves memory (Copy-on-Write) 
# and improves boot time.
preload_app!

# --- 3. BASIC CONFIGURATION ---

# Specifies the `port` that Puma will listen on; default is 3000.
port ENV.fetch("PORT") { 3000 }

# Specifies the environment (production, development, etc.).
environment ENV.fetch("RAILS_ENV") { "development" }

# Specify the PID file. In production, this file is necessary for process management.
# It defaults to tmp/pids/server.pid
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Run the Solid Queue supervisor inside of Puma for single-server deployments.
# (Keeping your existing custom plugin line)
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# --- 4. ON WORKER BOOT (Required for Multi-process setup) ---
# If you are using Active Record, you must configure the connection pool to be
# ready for each worker.
on_worker_boot do
  # Worker-specific setup for Active Record.
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end