#!/bin/bash

dapr run --app-id simple-dapr-server --app-port 5000 --log-level debug -- dotnet run --urls "http://[::1]:5000"