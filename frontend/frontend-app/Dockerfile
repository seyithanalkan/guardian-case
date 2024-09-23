# Use the official Node.js 22 image to build the React app
FROM node:22 as build

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json ./
RUN npm install

# Copy the rest of the application
COPY . .

# Build the React app with the environment variable injected at build time
ARG REACT_APP_BACKEND_URL
ENV REACT_APP_BACKEND_URL=${REACT_APP_BACKEND_URL}
RUN npm run build

# Serve the React app using Nginx
FROM nginx:alpine

# Copy built React app to Nginx HTML directory
COPY --from=build /app/build /usr/share/nginx/html

ARG REACT_APP_BACKEND_URL
ENV REACT_APP_BACKEND_URL=${REACT_APP_BACKEND_URL}

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]

#deploy#####