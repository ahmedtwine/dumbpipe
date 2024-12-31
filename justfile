# List available commands
default:
    @just --list

# Start development with hot reloading
# Usage: just dev [args]
# Example: just dev listen
dev *args:
    cargo watch -x run -- {{args}}

# Install project dependencies and tools
# Run this first when setting up the project
setup:
    cargo install cargo-watch
    cargo fetch
    @echo "Setup complete! You can now run 'just dev' to start development"

# Build the project in debug mode
build:
    cargo build

# Build the project in release mode
build-release:
    cargo build --release

# Run the project (add your arguments after --)
# Usage: just run [args]
# Example: just run listen
run *args:
    cargo run -- {{args}}

# Run tests
test:
    cargo test

# Run tests with output
test-verbose:
    cargo test -- --nocapture

# Check code formatting
check-format:
    cargo fmt -- --check

# Format code
format:
    cargo fmt

# Run clippy for linting
lint:
    cargo clippy -- -D warnings

# Clean build artifacts
clean:
    cargo clean

# Install dumbpipe globally
install:
    cargo install --path .
    @echo "dumbpipe installed! You can now use 'dumbpipe' command directly"

# Run video streaming example (Mac OS)
# This will start a video stream from your camera
# Steps:
# 1. Run this command to start streaming: just stream-video
# 2. Copy the ticket string that appears after "To connect, use:"
# 3. On another machine, run: just connect <ticket>
# Note: If you see pixel format errors, try stream-video-nv12 instead
stream-video:
    @echo "Starting video stream... Copy the ticket that appears after 'To connect, use:'"
    @echo "Press [q] to stop streaming"
    ffmpeg -f avfoundation -r 30 -i "0" -pix_fmt yuv420p -f mpegts - | cargo run -- listen

# Alternative video streaming with nv12 format
# Use this if the default stream-video shows pixel format errors
stream-video-nv12:
    @echo "Starting video stream with nv12 format... Copy the ticket that appears after 'To connect, use:'"
    @echo "Press [q] to stop streaming"
    ffmpeg -f avfoundation -r 30 -i "0" -pix_fmt nv12 -f mpegts - | cargo run -- listen

# Start TCP listener for web server forwarding
# Steps:
# 1. Start your local web server (e.g., npm run dev on port 3000)
# 2. Run: just listen-tcp [port]
# 3. Copy the ticket string that appears
# 4. On another machine, run: just connect-tcp <ticket> [port]
listen-tcp port="3000":
    @echo "Starting TCP listener for localhost:{{port}}..."
    @echo "Copy the ticket that appears and use it with 'just connect-tcp <ticket>'"
    cargo run -- listen-tcp --host localhost:{{port}}

# Connect to TCP listener
# Usage: just connect-tcp <ticket> [port]
# Example: just connect-tcp nodeabcd... 8080
connect-tcp ticket port="3001":
    @echo "Connecting to remote host... Will listen on localhost:{{port}}"
    cargo run -- connect-tcp --addr 0.0.0.0:{{port}} {{ticket}}

# Check all (format, lint, and test)
check-all: check-format lint test
    @echo "All checks passed!"
