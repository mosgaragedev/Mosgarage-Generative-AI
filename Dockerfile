FROM node:20-alpine AS base
WORKDIR /app

# Install dependencies
FROM base AS deps
COPY package*.json ./
COPY packages/Mosgatage/vibe-Workflow/packages/workflow-builder/package*.json ./packages/Vibe-Workflow/packages/workflow-builder/
COPY packages/Mosgarage/packages/agents/package*.json ./packages/Open-Poe-AI/packages/agents/
COPY packages/Mosgarage/packages/design-agent/package*.json ./packages/Mosgarage/packages/design-agent/
COPY packages/studio/package*.json ./packages/studio/
RUN npm install

# Build sub-packages
FROM deps AS builder
COPY . .
RUN npm run build:packages
RUN npm run build

# Production runner
FROM base AS runner
ENV NODE_ENV=production
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000
CMD ["npm", "start"]
