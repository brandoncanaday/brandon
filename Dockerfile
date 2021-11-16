ARG PROJECT_NAME

# setup base image

FROM node:16 AS base

ARG PROJECT_NAME
ENV PROJECT_HOME /projects/${PROJECT_NAME}
WORKDIR ${PROJECT_HOME}

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends bash git \
    && rm -rf /var/lib/apt/lists/*

COPY .markdownlint.yaml ./
COPY .markdownlintignore ./
COPY .eslintignore ./
COPY .eslintrc.json ./
COPY .env ./
COPY tsconfig.json ./
COPY package.json ./
COPY yarn.lock ./
COPY README.md ./
COPY public/ ./public
COPY src/ ./src

# install packages

FROM base AS packager

ARG PROJECT_NAME
ENV PROJECT_HOME /projects/${PROJECT_NAME}
WORKDIR ${PROJECT_HOME}

RUN yarn --frozen-lockfile

# lint app

FROM packager AS lint

ARG PROJECT_NAME
ENV PROJECT_HOME /projects/${PROJECT_NAME}
WORKDIR ${PROJECT_HOME}

COPY --from=base ${PROJECT_HOME}/public ./public
COPY --from=base ${PROJECT_HOME}/src ./src

RUN yarn run docker:lint

# build app

FROM packager AS build

ARG PROJECT_NAME
ENV PROJECT_HOME /projects/${PROJECT_NAME}
WORKDIR ${PROJECT_HOME}

COPY --from=base ${PROJECT_HOME}/public ./public
COPY --from=base ${PROJECT_HOME}/src ./src

RUN yarn run docker:build

# export build output

FROM scratch AS build-output

ARG PROJECT_NAME
ENV PROJECT_HOME /projects/${PROJECT_NAME}

COPY --from=build ${PROJECT_HOME}/dist/ /dist/

# test app

FROM packager AS test

ARG PROJECT_NAME
ENV PROJECT_HOME /projects/${PROJECT_NAME}
WORKDIR ${PROJECT_HOME}

COPY --from=base ${PROJECT_HOME}/public ./public
COPY --from=base ${PROJECT_HOME}/src ./src

RUN yarn run docker:test

# export test output

FROM scratch as test-output

ARG PROJECT_NAME
ENV PROJECT_HOME /projects/${PROJECT_NAME}

COPY --from=test ${PROJECT_HOME}/coverage/ /coverage/

# validate app

FROM packager AS validate

ARG PROJECT_NAME
ENV PROJECT_HOME /projects/${PROJECT_NAME}
WORKDIR ${PROJECT_HOME}

COPY --from=base ${PROJECT_HOME}/public ./public
COPY --from=base ${PROJECT_HOME}/src ./src

RUN yarn run docker:lint \
    && yarn run docker:build \
    && yarn run docker:test

# export validate output

FROM scratch as validate-output

ARG PROJECT_NAME
ENV PROJECT_HOME /projects/${PROJECT_NAME}

COPY --from=validate ${PROJECT_HOME}/dist/ /dist/
COPY --from=validate ${PROJECT_HOME}/coverage/ /coverage/

# serve app and watch files

FROM packager AS start-local

ARG PROJECT_NAME
ENV PROJECT_HOME /projects/${PROJECT_NAME}
WORKDIR ${PROJECT_HOME}

COPY config.js ./
COPY --from=base ${PROJECT_HOME}/public ./public
COPY --from=base ${PROJECT_HOME}/src ./src

EXPOSE 3000

ENTRYPOINT ["yarn", "docker:start-local"]
