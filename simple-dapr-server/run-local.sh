#!/bin/bash

dapr run --app-id simple-dapr-server --app-port 50051 --app-protocol grpc --log-level debug -- python3 server.py