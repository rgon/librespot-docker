#!/bin/bash
if [ ! -f .env ]
then
  export $(cat .env | xargs)
fi

docker compose build && docker compose up -d
