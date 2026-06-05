# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy dependency files
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build the app
RUN pnpm build

# Production stage
FROM node:22-alpine

WORKDIR /app

# Install pnpm for running the preview if needed, or just use node
RUN npm install -g pnpm

# Copy built app and dependencies
COPY --from=builder /app/build ./build
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-lock.yaml ./pnpm-lock.yaml

# Install production dependencies only
RUN pnpm install --prod --frozen-lockfile

# Expose SvelteKit port
EXPOSE 3000

ENV NODE_ENV=production

# Run the app
CMD ["node", "build"]
