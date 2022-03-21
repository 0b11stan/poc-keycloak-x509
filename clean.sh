#!/bin/bash

docker-compose down --volumes
rm */*.srl */*.pem */*.p12 */*.jks
