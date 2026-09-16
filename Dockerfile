# Node 16 but smaller images so less attack surface 
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev # production deps only, no jest/supertest in the image

COPY app.js ./

EXPOSE 8081
CMD ["node", "app.js"]
