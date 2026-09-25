FROM node:18-bookworm-slim

# Set up directory for the server
RUN mkdir /app/
WORKDIR /app/

# Front-end: use pre-built dist when present (recommended on low-RAM servers).
COPY front-end/ /app/front-end/
WORKDIR /app/front-end/
RUN if [ -f dist/index.html ]; then \
      echo "Using pre-built front-end/dist, skipping npm install and build"; \
    else \
      npm ci --legacy-peer-deps && \
      NODE_OPTIONS=--max-old-space-size=1536 npm run-script build; \
    fi

WORKDIR /app/
COPY package.json package-lock.json /app/
RUN npm install

COPY server.js /app/
COPY probe.js /app/
COPY constants.js /app/
COPY notification.js /app/
COPY database.js /app/
COPY api.js /app/
COPY app.js /app/
COPY utils.js /app/
COPY docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh
COPY templates /app/templates

# Expose both HTTP and HTTPS ports
EXPOSE 80
EXPOSE 443

# Start the server
ENTRYPOINT ["/app/docker-entrypoint.sh"]
