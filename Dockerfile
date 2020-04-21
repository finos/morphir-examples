FROM node:8-alpine
WORKDIR /app
COPY dapr-output/ .
RUN npm install
EXPOSE 3000
CMD [ "node", "DaprAppShell.js" ]