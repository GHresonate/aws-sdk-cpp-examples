### --------------------------------------------------------------------
### Docker Build Arguments
### Available only during Docker build - `docker build --build-arg ...`
### --------------------------------------------------------------------
ARG AWS_SDK_CPP_VERSION="1.8.160"
ARG GITHUB_OWNER="aws"
ARG GITHUB_REPOSITORY="aws-sdk-cpp"
ARG AWS_SDK_BUILD_ONLY="s3"
ARG AWS_SDK_CPP_BUILD_TYPE="Release"
ARG APP_BUILD_TYPE="Release"
ARG APP_USER_NAME="appuser"
ARG APP_USER_ID="1000"
ARG APP_GROUP_NAME="appgroup"
ARG APP_GROUP_ID="1000"
ARG APP_MOUNT_VOLUME="false"
### --------------------------------------------------------------------


### --------------------------------------------------------------------
### Base image
### --------------------------------------------------------------------
FROM ubuntu:20.04 as base

# Fix tzdata hang
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN \
    apt-get update && \
    apt-get install -y \
    curl wget git zip unzip \
    make cmake g++ \
    libcurl4-openssl-dev libssl-dev libpulse-dev \
    uuid-dev zlib1g-dev


### --------------------------------------------------------------------
### Build aws-sdk-cpp
### --------------------------------------------------------------------
FROM base as build-aws-sdk-cpp
ARG AWS_SDK_CPP_VERSION
ARG GITHUB_OWNER
ARG GITHUB_REPOSITORY
ARG AWS_SDK_CPP_BUILD_TYPE
ARG AWS_SDK_BUILD_ONLY
ENV AWS_SDK_CPP_VERSION="${AWS_SDK_CPP_VERSION}" \
    AWS_SDK_CPP_BUILD_TYPE="${AWS_SDK_CPP_BUILD_TYPE}" \
    AWS_SDK_BUILD_ONLY="${AWS_SDK_BUILD_ONLY}" \
    GITHUB_OWNER="${GITHUB_OWNER}" \
    GITHUB_REPOSITORY="$GITHUB_REPOSITORY"
ENV ZIP_FILEPATH="${GITHUB_REPOSITORY}-${AWS_SDK_CPP_VERSION}.zip"

RUN ln -sf /bin/bash /bin/sh
WORKDIR /sdk_build/
ENV GITHUB_URL="https://github.com/${GITHUB_OWNER}/${GITHUB_REPOSITORY}/archive/${AWS_SDK_CPP_VERSION}.zip"
RUN curl -sL -o "$ZIP_FILEPATH" "$GITHUB_URL" && \
    unzip -qq "$ZIP_FILEPATH" && rm "$ZIP_FILEPATH" && \
    cmake "${GITHUB_REPOSITORY}-${AWS_SDK_CPP_VERSION}" -DBUILD_ONLY="${AWS_SDK_BUILD_ONLY}" -DCMAKE_BUILD_TYPE="${AWS_SDK_CPP_BUILD_TYPE}" \
    -DENABLE_TESTING=OFF && \
    make && \
    make install


### --------------------------------------------------------------------
### Build the application
### --------------------------------------------------------------------
FROM build-aws-sdk-cpp as build-app
ARG APP_MOUNT_VOLUME
WORKDIR /code/
COPY . .
ARG APP_BUILD_TYPE
ENV APP_BUILD_TYPE="${APP_BUILD_TYPE}"
RUN rm -rf build && cmake -S . -B build -DCMAKE_BUILD_TYPE="${APP_BUILD_TYPE}"
WORKDIR /code/build/
RUN make && if [[ "$APP_MOUNT_VOLUME" = "true" ]] ; then rm -rf /code ; fi


### --------------------------------------------------------------------
### Final application image
### --------------------------------------------------------------------
FROM ubuntu:20.04 as app
RUN apt-get update && \
    apt-get install -y libcurl4

ARG APP_USER_NAME
ARG APP_USER_ID
ARG APP_GROUP_ID
ARG APP_GROUP_NAME

RUN groupadd --gid "$APP_GROUP_ID" "$APP_GROUP_NAME" \
    && useradd --uid "$APP_USER_ID" --gid "${APP_GROUP_ID}" --shell /bin/bash "$APP_USER_NAME"
USER "$APP_USER_NAME"
COPY --from=build-app /usr/local/lib/*.so* /usr/local/lib/
COPY --from=build-app /usr/local/bin/. /usr/local/bin/
# # ENTRYPOINT [ "/usr/local/bin/s3-demo" ]
