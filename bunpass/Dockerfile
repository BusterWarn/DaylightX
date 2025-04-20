FROM oven/bun:1.0 AS base

WORKDIR /app

# Copy package.json first
COPY package.json ./

# Install dependencies (without requiring a lockfile)
RUN bun install

# Copy application code
COPY . .

# Expose the port the app will run on
EXPOSE 3000

# Start the application
CMD ["bun", "start"]
