#!/usr/bin/env bash

strace ./hellpod.sh 1 1 2>&1 | grep X_OK