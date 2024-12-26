# Use Node.js base image
FROM node:16

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY app/package.json .
RUN npm install

# Copy the application code
COPY app/ .

# Expose port 8000
EXPOSE 8000

# Start the server
CMD ["npm", "start"]
