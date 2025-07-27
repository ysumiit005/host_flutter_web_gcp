# Stage 1: Build the Flutter web application
FROM cirrusci/flutter:stable AS build

# Set the working directory
WORKDIR /app

# Copy pubspec.yaml and pubspec.lock to leverage Docker cache
COPY pubspec.yaml pubspec.lock ./

# Get Flutter dependencies
RUN flutter pub get

# Copy the rest of the application source code
COPY . .

# Build the Flutter web application for release
# --web-renderer html is generally good for broader compatibility
# --base-href / ensures correct asset loading if served from a subpath (e.g. Cloud Run)
RUN flutter build web --release --web-renderer html --base-href /

# Stage 2: Serve the static files using Nginx
FROM nginx:alpine

# Copy the Nginx default configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built Flutter web app from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80 for the web server
EXPOSE 80

# Command to run Nginx
CMD ["nginx", "-g", "daemon off;"]
