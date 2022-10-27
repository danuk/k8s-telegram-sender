TAG="0.0.1"

docker build \
    -t danuk/telegram-sender:${TAG} \
    -t danuk/telegram-sender:latest .

docker push danuk/telegram-sender:${TAG}
docker push danuk/telegram-sender:latest

