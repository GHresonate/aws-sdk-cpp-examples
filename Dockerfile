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
    cmake g++ gcc \
    libcurl4-openssl-dev libssl-dev libpulse-dev \
    uuid-dev zlib1g-dev
RUN apt-get update && \
    apt-get install -y \
    make golang-1.13
ENV PATH="$PATH:/usr/lib/go-1.13/bin"


### --------------------------------------------------------------------
### Build aws-sdk-cpp
### --------------------------------------------------------------------
FROM base as build-aws-sdk-cpp
ARG AWS_SDK_CPP_VERSION
ARG GITHUB_OWNER="aws"
ARG GITHUB_REPOSITORY="aws-sdk-cpp"
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
ENV GITHUB_URL="https://github.com/aws/aws-sdk-cpp/archive/${AWS_SDK_CPP_VERSION}.zip"
RUN curl -sL -o "$ZIP_FILEPATH" "$GITHUB_URL"
RUN unzip -qq "$ZIP_FILEPATH"
RUN cmake "aws-sdk-cpp-${AWS_SDK_CPP_VERSION}" -DBUILD_ONLY="${AWS_SDK_BUILD_ONLY}" -DCMAKE_BUILD_TYPE="${AWS_SDK_CPP_BUILD_TYPE}"
RUN make
RUN make install


### --------------------------------------------------------------------
### Build the application
### --------------------------------------------------------------------
FROM build-aws-sdk-cpp as build-app
WORKDIR /code/
COPY . .
ARG APP_BUILD_TYPE
ENV APP_BUILD_TYPE="${APP_BUILD_TYPE}"
RUN rm -rf build && cmake -S . -B build -DCMAKE_BUILD_TYPE="${APP_BUILD_TYPE}"
WORKDIR /code/build/
RUN make && rm -rf /code/


### --------------------------------------------------------------------
### Final application image
### --------------------------------------------------------------------
FROM ubuntu:20.04 as app
RUN apt-get update && \
    apt-get install -y libcurl4
COPY --from=build-app /usr/local/lib/*.so* /usr/local/lib/
COPY --from=build-app /usr/local/bin/. /usr/local/bin/
# ENTRYPOINT [ "/usr/local/bin/s3-demo" ]
