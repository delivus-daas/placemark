FROM --platform=amd64  node:20-slim

WORKDIR /home/ubuntu/placemark

ENV PATH /home/ubuntu/placemark/node_modules/.bin:$PATH

RUN apt-get update \
  && apt-get install -y openssl --no-install-recommends \
  && apt-get install -y tini --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && chown -R root:root /home/ubuntu/placemark

# This has to happen before USER node, because after
# that line, we don't have permission to run corepack enable.
RUN corepack enable

USER root

# Install dependencies based on the preferred package manager
#COPY --chown=ubuntu:ubuntu package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

RUN \
  if [ -f yarn.lock ]; then yarn config list && yarn install --frozen-lockfile && yarn cache clean --force; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i; \
  # Allow install without lockfile, so example works even without Node.js installed locally
  else echo "Warning: Lockfile not found. It is recommended to commit lockfiles to version control." && yarn inst
  fi

# TODO: this would be nice to change. Like,
# moving source to src
#COPY --chown=ubuntu:ubuntu  . .

RUN \
  if [ -f yarn.lock ]; then yarn config list && yarn build; \
  elif [ -f package-lock.json ]; then npm run build; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm run build; \
  # Allow install without lockfile, so example works even without Node.js installed locally
  else echo "Warning: Lockfile not found. It is recommended to commit lockfiles to version control." && yarn install; \
  fi

# Next.js collects completely anonymous telemetry data about general usage. Learn more here: https://nextjs.org/telemetry
# Uncomment the following line to disable telemetry at run time
ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV production
ENV PORT 80

# Note: Don't expose ports here, Compose will handle that for us

ENTRYPOINT ["tini", "--"]

# Start Next.js in development mode based on the preferred package manager
CMD \
  if [ -f yarn.lock ]; then yarn start; \
  elif [ -f package-lock.json ]; then npm start; \

  elif [ -f pnpm-lock.yaml ]; then pnpm start; \
  else npm start; \
  fi
