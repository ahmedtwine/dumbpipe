# Dumb pipe

This is an example to use [iroh-net](https://crates.io/crates/iroh-net) to create a dumb pipe to connect two machines with a QUIC connection.

Iroh-net will take case of hole punching and NAT traversal whenever possible, and fall back to a
relay if hole punching does not succeed.

It is also useful as a standalone tool for quick copy jobs.

This is inspired by the unix tool [netcat](https://en.wikipedia.org/wiki/Netcat). While netcat
works with IP addresses, dumbpipe works with 256 bit node ids and therefore is somewhat location transparent. In addition, connections are encrypted using TLS.

# Installation

## For Development/Testing

Clone the repository and use cargo run:
```bash
git clone https://github.com/yourusername/dumbpipe.git
cd dumbpipe
cargo build
```

For development testing, replace all `dumbpipe` commands with `cargo run --`. For example:
```bash
cargo run -- listen
```

## For Production Use
```bash
cargo install dumbpipe
```

# Examples

## Use dumbpipe to stream video using [ffmpeg / ffplay](https://ffmpeg.org/):

This example demonstrates how to create a video stream between two machines using ffmpeg and dumbpipe. The stream uses standard input/output for data transfer.

### Sender side (Machine A)

On Mac OS (Development):
```bash
# Using cargo run for development
ffmpeg -f avfoundation -r 30 -i "0" -pix_fmt yuv420p -f mpegts - | cargo run -- listen
```

On Mac OS (Production):
```bash
# Using installed dumbpipe
ffmpeg -f avfoundation -r 30 -i "0" -pix_fmt yuv420p -f mpegts - | dumbpipe listen
```

On Linux:
```bash
# Using cargo run for development
ffmpeg -f v4l2 -i /dev/video0 -r 30 -preset ultrafast -vcodec libx264 -tune zerolatency -f mpegts - | cargo run -- listen

# Using installed dumbpipe
ffmpeg -f v4l2 -i /dev/video0 -r 30 -preset ultrafast -vcodec libx264 -tune zerolatency -f mpegts - | dumbpipe listen
```

The command will output a ticket (a long string) that you'll need for the receiver side.

### Receiver side (Machine B)

Development:
```bash
cargo run -- connect <TICKET> | ffplay -f mpegts -fflags nobuffer -framedrop -
```

Production:
```bash
dumbpipe connect <TICKET> | ffplay -f mpegts -fflags nobuffer -framedrop -
```

Replace `<TICKET>` with the ticket string from the sender side.

Notes:
- Adjust the ffmpeg options based on your local platform and video capture devices
- The ticket is a unique identifier for the connection and must be copied from sender to receiver
- For Mac, "0" in `-i "0"` refers to the default video device

## Forward development web server

This example shows how to share a local development web server with someone outside your network.

### Step 1: Start your web server
```bash
npm run dev
>    - Local:        http://localhost:3000
```

### Step 2: Start dumbpipe listener (Machine A)

Development:
```bash
cargo run -- listen-tcp --host localhost:3000
```

Production:
```bash
dumbpipe listen-tcp --host localhost:3000
```

This will output a ticket string.

### Step 3: Connect from remote machine (Machine B)

Development:
```bash
cargo run -- connect-tcp --addr 0.0.0.0:3001 <TICKET>
```

Production:
```bash
dumbpipe connect-tcp --addr 0.0.0.0:3001 <TICKET>
```

Replace `<TICKET>` with the ticket from Step 2.

### Step 4: Access the website
On Machine B, you can now access the website at `http://localhost:3001`

# Advanced features

## Custom ALPNs

Dumbpipe supports custom [ALPN](https://en.wikipedia.org/wiki/Application-Layer_Protocol_Negotiation) strings for expert users who need to interact with existing iroh-net services.

Example using iroh-bytes protocol:

Development:
```bash
echo request1.bin | cargo run -- connect <TICKET> --custom-alpn utf8:/iroh-bytes/2 > response1.bin
```

Production:
```bash
echo request1.bin | dumbpipe connect <TICKET> --custom-alpn utf8:/iroh-bytes/2 > response1.bin
```

If request1.bin contains a valid request for the `/iroh-bytes/2` protocol, response1.bin will contain the response.
