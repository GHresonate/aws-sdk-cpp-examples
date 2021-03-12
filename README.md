# docker-aws-sdk-cpp

An example of how to a build C++ application that uses AWS's SDK.

## Requirements

- [Docker](https://docs.docker.com/get-docker/)
- AWS account with existing S3 buckets to test the [s3-demo](./src/s3-demo.cpp) application

## Usage

### Build

```bash
$ git clone https://github.com/unfor19/docker-aws-sdk-cpp.git
$ cd docker-aws-sdk-cpp
$ docker build -t unfor19/aws-sdk-cpp .
```

### Run

The executeable `s3-demo` is copied `/usr/local/bin` during the build time. The demo application consumes only one argument - `region`

```bash
# Using environment variables
$ docker run --rm -it \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_SESSION_TOKEN unfor19/aws-sdk-cpp:latest s3-demo eu-west-1
# Output: List of buckets ...


# Using configuration file in readonly mode (haven't tested it)
$ docker run --rm -it -v $HOME/.aws/:/root/.aws/:ro unfor19/aws-sdk-cpp:latest s3-demo eu-west-1
# Output: List of buckets ...
```

## Development

### Build

```bash
$ git clone https://github.com/unfor19/docker-aws-sdk-cpp.git
$ cd docker-aws-sdk-cpp

# (Optoinal) Build the application in Debug mode
export APP_BUILD_TYPE="Debug" # or Release

$ docker build -t unfor19/aws-sdk-cpp --target build-app --build-arg APP_BUILD_TYPE="$APP_BUILD_TYPE" .
```

### Run

Mount this project to the container and then build the application.

```bash
# Change something in src/s3-demo.cpp with local IDE and build the application while in the container

# Using environment variables
$ docker run --rm -it -v "$PWD"/:/code/ \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_SESSION_TOKEN unfor19/aws-sdk-cpp:src bash

root@852c75b69bd4:/code/build# s3-demo eu-west-1
# Output: List of buckets ...


# Change something in src/s3-demo.cpp with local IDE and build the application while in the container
root@852c75b69bd4:/code/build# make
root@852c75b69bd4:/code/build# s3-demo eu-west-1
# Output: List of buckets ...
```

### Build Only aws-sdk-cpp

```bash
docker build --target build-aws-sdk-cpp -t unfor19/aws-sdk-cpp:src .
```

## TODO

- Dockerfile - Change final image from `ubuntu` to `alpine`
- Add Debug target

## Authors

Created and maintained by [Meir Gabay](https://github.com/unfor19)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/unfor19/docker-aws-sdk-cpp/blob/master/LICENSE) file for details
