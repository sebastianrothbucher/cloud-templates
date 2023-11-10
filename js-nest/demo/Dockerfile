FROM node:18-alpine

COPY dist dist
COPY node_modules node_modules
COPY package*.json .

CMD node dist/main.js
