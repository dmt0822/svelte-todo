FROM node:12.14.1-alpine
COPY . /
RUN npm install
RUN npm run build
RUN npm run prune
WORKDIR /
RUN addgroup -S appgroup
RUN adduser -S appuser -G appgroup
USER appuser

CMD ["npm", "start"]