#!/bin/bash

[ -z "$SSH_AGENT_PID" ] || eval $(ssh-agent -k)
