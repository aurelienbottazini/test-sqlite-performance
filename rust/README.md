To build for raspberry pi:

    sudo apt install gcc-arm-linux-gnueabihf
    rustup target add armv7-unknown-linux-gnueabihf
    cargo build --target armv7-unknown-linux-gnueabihf
