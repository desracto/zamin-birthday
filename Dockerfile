# Stage 1: Build the Next.js app
FROM node:18 AS builder

# Set working directory inside the container
WORKDIR /app

# Copy only the necessary files to install dependencies
COPY package.json package-lock.json ./ 

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the Next.js app
RUN npm run build

# Stage 2: Create a lightweight image for production
FROM node:18-alpine AS runner

# Set working directory
WORKDIR /app

# Install `serve` to run the production build
RUN npm install -g serve

# Copy built assets from the previous stage
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package.json ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

# Expose port
EXPOSE 3000

# Command to run the Next.js app in production
CMD ["serve", "-s", "-l", "3000", "./.next"]
