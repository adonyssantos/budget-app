# Root Dockerfile (supports both frontend and backend apps)

# Stage 1: Install development dependencies
FROM node:20-alpine AS development-dependencies-env
RUN npm install -g pnpm
WORKDIR /app
COPY . . 
RUN pnpm install --no-frozen-lockfile

# Stage 2: Install production dependencies
FROM node:20-alpine AS production-dependencies-env
RUN npm install -g pnpm
WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps ./apps
COPY packages ./packages
RUN pnpm install --prod --no-frozen-lockfile

# Stage 3: Build frontend and backend apps
FROM node:20-alpine AS build-env
RUN npm install -g pnpm
WORKDIR /app
COPY . . 
COPY --from=development-dependencies-env /app/node_modules /app/node_modules
RUN pnpm run build

# Stage 4: Production image for frontend
FROM node:20-alpine AS frontend
RUN npm install -g pnpm
WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/budget-app-frontend ./apps/budget-app-frontend
COPY packages ./packages
COPY --from=production-dependencies-env /app/node_modules /app/node_modules
COPY --from=build-env /app/apps/budget-app-frontend/build ./apps/budget-app-frontend/build
CMD ["pnpm", "start:frontend"]

# Stage 5: Production image for backend
FROM node:20-alpine AS backend
RUN npm install -g pnpm
WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/budget-app-backend ./apps/budget-app-backend
COPY packages ./packages
COPY --from=production-dependencies-env /app/node_modules /app/node_modules
COPY --from=build-env /app/apps/budget-app-backend/dist ./apps/budget-app-backend/dist
CMD ["pnpm", "start:backend"]
