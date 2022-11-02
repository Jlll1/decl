FROM alpine:latest

RUN apk add --update neovim

WORKDIR /root/.config/nvim
RUN echo "require('test/test').run()" >> init.lua

CMD ["nvim", "--headless", "+qa!"]
