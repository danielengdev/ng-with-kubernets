# Stage 1: build the Angular app
FROM node:22.12-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --silent
COPY . .
RUN npm run build

# Stage 2: nginx to serve static files
FROM nginx:1.23-alpine

# Create a non-root user (security)
RUN addgroup -S web && adduser -S web -G web

# Prepare nginx folders and fix permissions
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx && \
    rm -rf /usr/share/nginx/html/* && \
    chown -R web:web /usr/share/nginx/html /etc/nginx/conf.d /var/cache/nginx /var/run /var/log/nginx

# Copy built Angular app
COPY --from=builder /app/dist/ng-kube/browser /usr/share/nginx/html

# Optional: custom nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Switch to non-root user
#USER web

EXPOSE 80

# Start Nginx (non-root safe)
CMD ["nginx", "-g", "daemon off;"]
