FROM node:20-alpine AS development-dependencies-env
RUN npm install -g pnpm
COPY . /app
WORKDIR /app
RUN pnpm install --no-frozen-lockfile

FROM node:20-alpine AS production-dependencies-env
RUN npm install -g pnpm
COPY ./package.json pnpm-lock.yaml /app/
WORKDIR /app
RUN pnpm install --prod --no-frozen-lockfile

FROM node:20-alpine AS build-env
RUN npm install -g pnpm
COPY . /app/
COPY --from=development-dependencies-env /app/node_modules /app/node_modules
WORKDIR /app
RUN pnpm run build

FROM node:20-alpine
RUN npm install -g pnpm
COPY ./package.json pnpm-lock.yaml /app/
COPY --from=production-dependencies-env /app/node_modules /app/node_modules
COPY --from=build-env /app/dist /app/dist
WORKDIR /app
CMD ["pnpm", "run", "start"]
