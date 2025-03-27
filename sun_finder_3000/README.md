# Install gleam
brew install gleam

# Add deps
gleam deps download
or
gleam add gleam_elli gleam_http gleam_hackney argv

# Start server
gleam run port <port>
