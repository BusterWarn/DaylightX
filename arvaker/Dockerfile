FROM ubuntu:24.04

# Prepare for Odin install
RUN apt update -qq \
  && apt install -y llvm clang git build-essential libssl-dev

# Install Odin
WORKDIR /Odin-install
RUN git clone https://github.com/odin-lang/Odin.git /Odin-install \
  && git checkout dev-2025-03 \
  && make

# Cleanup after Odin install
RUN mkdir /opt/Odin \
  && cp -R ./base ./core ./shared ./vendor ./odin /opt/Odin/
WORKDIR /

RUN rm -rf /Odin-install

# Add Odin to path
ENV PATH="/opt/Odin:${PATH}"
# Move to /app
WORKDIR /app

# Download Odin http lib
RUN git clone https://github.com/laytan/odin-http.git lib/odin-http

# Copy Arvaker source files
COPY src/ ./src/

# Expose port 8080
EXPOSE 8080

# Start Arvaker
CMD ["odin", "run", "src"]
