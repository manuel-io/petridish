## Prepare

    sudo apt-get update
    sudo apt-get install gcc-arm-none-eabi
    sudo apt-get install qemu
    sudo apt-get install make
    sudo apt-get install xvfb (optional)

## Integrator CP

    make CROSS_COMPILE=arm-linux-gnu- \
      || make CROSS_COMPILE=arm-none-eabi-
    make deploy

## Docker

    sudo docker build -t integrator .
    sudo docker run --rm -it integrator bash
    sudo xvfb-run make deploy
