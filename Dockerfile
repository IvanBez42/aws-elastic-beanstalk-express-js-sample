# Node 22 LTS (currently maintained) - Node 16 is EOL, Trivy flagged CVEs
FROM node:22-alpine

RUN apk update && apk upgrade --no-cache # another security automation

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev # production deps only, no jest/supertest in the image
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx # sly solution, just remove it before it hits production

COPY app.js ./

EXPOSE 8080
CMD ["node", "app.js"]
