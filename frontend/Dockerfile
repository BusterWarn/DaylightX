# Stage 1: Build the Svelte application
FROM node:20-alpine AS build

WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Serve with nginx
FROM nginx:alpine

# Copy the built files from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy a custom nginx configuration to serve the SPA properly
RUN echo 'server {\
    listen 8080;\
    root /usr/share/nginx/html;\
    index index.html;\
    add_header Cache-Control "no-store, no-cache, must-revalidate";\
    location / {\
        try_files $uri $uri/ /index.html;\
    }\
    location /api/bunpass {\
        proxy_pass http://bunpass-service:3000/api/locations;\
        proxy_set_header Host $host;\
        proxy_set_header X-Real-IP $remote_addr;\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\
        proxy_set_header X-Forwarded-Proto $scheme;\
    }\
    location /api/health {\
        proxy_pass http://janus-service:4000/api/health;\
        proxy_set_header Host $host;\
        proxy_set_header X-Real-IP $remote_addr;\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\
        proxy_set_header X-Forwarded-Proto $scheme;\
    }\
}' > /etc/nginx/conf.d/default.conf

# Expose port 8080
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
