# TTRSS Containers

## Maintainer

- [Alexandre Chanu](https://github.com/achanu)

## Build
* podman build -f ttrss-phpfpm.Dockerfile -t ttrss:phpfpm
* podman build -f ttrss-daemon.Dockerfile -t ttrss:daemon

## Usage
* podman run -d quay.io/achanu/ttrss:phpfpm
* podman run -d quay.io/achanu/ttrss:daemon

## [License](LICENSE)

[GPLv3](LICENSE)
