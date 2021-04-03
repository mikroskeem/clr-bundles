# Clear Linux bundles

Here are the Clear Linux bundles I use.

## Usage

Use `./docker/build_docker.sh` to build the Docker image for managing the swupd repository.

Use `./build.sh` to output a repository tarball into the stdout (e.g `./build.sh > clr-repo.tar`)

To get metadata about the repository tarball, you can use `tar -O -xf clr-repo.tar ./.clr.json | jq` to get
Clear Linux version this repository was built with.
