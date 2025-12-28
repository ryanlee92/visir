# Use Node.js LTS version
FROM node:20

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install

# Copy source files
COPY . .

# Build TypeScript
RUN npm run build

# Expose the port
EXPOSE 8080

# Start the server
CMD [ "npm", "start" ]