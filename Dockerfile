# Node 22 LTS (currently maintained) - Node 16 is EOL, Trivy flagged CVEs
FROM node:22-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev # production deps only, no jest/supertest in the image

COPY app.js ./

EXPOSE 8080
CMD ["node", "app.js"]
