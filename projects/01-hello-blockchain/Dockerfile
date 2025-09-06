# Use official Node.js LTS image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install Python and build tools (needed for some native modules)
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy project files
COPY . .

# Expose port for local network
EXPOSE 8545

# Default command
CMD ["npx", "hardhat", "node"]
