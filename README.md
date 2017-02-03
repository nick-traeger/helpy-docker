# Helpy.io Docker Image

This repository contains the neccessary files to build and run your own containerized Helpy.io instance. The container is designed to run standalone or on OpenShift Origin.

## Installation

This image is available on DockerHub. To pull it, run:

```
docker pull computersciencehouse/helpy
```

## Usage

This image expects a number of environment variables to be set to properly run:

- `POSTGRES_HOST` should be set to the hostname or IP address of your PostgreSQL server
- `POSTGRES_DB` should be set to the name of your database
- `POSTGRES_USER` should be set to the name of your database user
- `POSTGRES_PASSWORD` should be set to the password for your database user
- `SECRET_KEY_BASE` should be set to a long, random string (used to sign and verify cookies)

You may also set `DO_NOT_PREPARE=true` to skip database migrations. It is advised to leave this alone to ensure database migrations run on version change.

When the image is run, the application will be served by Unicorn on port 8080.

## Storage

The application will store uploaded files in `/helpy/uploads`. A volume should be mounted in this location to provide persistant storage.
