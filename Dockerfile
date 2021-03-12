### --------------------------------------------------------------------
### Docker Build Arguments
### Available only during Docker build - `docker build --build-arg ...`
### --------------------------------------------------------------------
ARG AWS_SDK_CPP_VERSION="1.8.160"
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
COPY scripts/ /usr/local/bin/
WORKDIR /code/


### --------------------------------------------------------------------
### Build aws-sdk-cpp
### --------------------------------------------------------------------
FROM base as build-aws-sdk-cpp
ARG AWS_SDK_CPP_VERSION
ARG AWS_SDK_CPP_BUILD_TYPE
ENV AWS_SDK_CPP_VERSION="${AWS_SDK_CPP_VERSION}" \
    AWS_SDK_CPP_BUILD_TYPE="${AWS_SDK_CPP_BUILD_TYPE}"
WORKDIR /code/
RUN download.sh "https://github.com/aws/aws-sdk-cpp/archive/${AWS_SDK_CPP_VERSION}.zip"
WORKDIR /sdk_build/
RUN cmake /code/aws-sdk-cpp-${AWS_SDK_CPP_VERSION} -DBUILD_ONLY="s3" -DCMAKE_BUILD_TYPE="${AWS_SDK_CPP_BUILD_TYPE}"
RUN make && \
    make install && \
    rm -rf /code/


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
RUN make


### --------------------------------------------------------------------
### Final application image
### --------------------------------------------------------------------
FROM ubuntu:20.04 as app

ENV DEBIAN_FRONTEND=noninteractive

# Fix tzdata hang
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install -y libcurl4

COPY --from=build-app /usr/local/bin/. /usr/local/bin/
COPY --from=build-app /usr/local/lib/. /usr/local/lib/
# ENTRYPOINT [ "/usr/local/bin/s3-demo" ]
