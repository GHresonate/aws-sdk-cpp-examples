# aws-sdk-cpp-examples

An example of how to a build C++ application that uses AWS's SDK.

## Requirements

- [Docker](https://docs.docker.com/get-docker/)
- AWS account with existing S3 buckets to test the [s3-demo](./src/s3-demo.cpp) application

## Usage

### Build

```bash
$ DOCKER_IMAGE="unfor19/aws-sdk-cpp-examples:latest" # ubuntu
# For Alpine:
# DOCKER_IMAGE="unfor19/aws-sdk-cpp:latest-alpine"

$ git clone https://github.com/unfor19/aws-sdk-cpp-examples.git
$ cd aws-sdk-cpp-examples
$ docker build -t "$DOCKER_IMAGE" .
# For Alpine:
# docker build -t "$DOCKER_IMAGE" -f Dockerfile.alpine .
```

### Run

The executeable `s3-demo` is copied `/usr/local/bin` during the build time. The demo application consumes only one argument - `region`

```bash
$ DOCKER_IMAGE="unfor19/aws-sdk-cpp-examples:latest" # ubuntu
# For Alpine:
# DOCKER_IMAGE="unfor19/aws-sdk-cpp-examples:latest-alpine"

# Using environment variables
$ docker run --rm -it \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_SESSION_TOKEN "$DOCKER_IMAGE" s3-demo eu-west-1
# Output: List of buckets ...

# Using configuration file in readonly mode (haven't tested it)
$ docker run --rm -it -v $HOME/.aws/:/root/.aws/:ro "$DOCKER_IMAGE" s3-demo eu-west-1
# Output: List of buckets ...
```

## Development

### Build

```bash
$ DOCKER_IMAGE="unfor19/aws-sdk-cpp-examples:latest-dev" # ubuntu
# For Alpine:
# DOCKER_IMAGE="unfor19/aws-sdk-cpp-examples:latest-alpine-dev"

$ git clone https://github.com/unfor19/aws-sdk-cpp-examples.git
$ cd aws-sdk-cpp-examples

$ docker build -t "$DOCKER_IMAGE" --target build-app --build-arg APP_MOUNT_VOLUME="true" .
# For Alpine: 
# docker build -t "$DOCKER_IMAGE" --target build-app --build-arg APP_MOUNT_VOLUME="true" . -f Dockerfile.alpine
```

### Run

Mount this project to the container and then build the application.

```bash
$ DOCKER_IMAGE="unfor19/aws-sdk-cpp:latest-dev" # ubuntu
# For Alpine:
# DOCKER_IMAGE="unfor19/aws-sdk-cpp:latest-alpine-dev"

# Change something in src/s3-demo.cpp with local IDE and build the application while in the container

# Using environment variables
$ docker run --rm -it -v "$PWD"/:/code/ \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_SESSION_TOKEN "$DOCKER_IMAGE" bash

root@852c75b69bd4:/code/build# s3-demo eu-west-1
# Output: List of buckets ...

# Change something in src/s3-demo.cpp with local IDE and build the application while in the container
root@852c75b69bd4:/code/build# make
root@852c75b69bd4:/code/build# s3-demo eu-west-1
# Output: List of buckets ...
```

### Build Only aws-sdk-cpp

```bash
$ DOCKER_IMAGE="unfor19/aws-sdk-cpp:latest-sdk" # ubuntu
# For Alpine:
# DOCKER_IMAGE="unfor19/aws-sdk-cpp:latest-alpine-sdk"

$ docker build -t "$DOCKER_IMAGE" --target build-aws-sdk-cpp  .
# For Alpine: 
# docker build -t "$DOCKER_IMAGE" --target build-aws-sdk-cpp . -f Dockerfile.alpine
```

## Authors

Created and maintained by [Meir Gabay](https://github.com/unfor19)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/unfor19/aws-sdk-cpp-examples/blob/master/LICENSE) file for details
