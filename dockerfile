FROM node:18

WORKDIR /app

COPY ./lambdas/Players/package*.json ./
RUN npm install

COPY ./lambdas/ .

CMD ["npm", "run", "test"]