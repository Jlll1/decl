FROM alpine:latest AS build-tree-sitter

RUN apk add --update build-base tree-sitter-dev
WORKDIR /root/.config/treesitter
COPY treesitter-parsers .
RUN mkdir parser
RUN gcc -shared -o parser/c_sharp.so -fPIC tree-sitter-c-sharp/src/parser.c tree-sitter-c-sharp/src/scanner.c
RUN gcc -shared -o parser/lua.so -fPIC tree-sitter-lua/src/parser.c tree-sitter-lua/src/scanner.c

FROM alpine:latest

RUN apk add --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community --update neovim
RUN apk add --update ripgrep

WORKDIR /root/.config/nvim/parser
COPY --from=build-tree-sitter /root/.config/treesitter/parser/* ./

WORKDIR /root/.config/nvim
RUN echo "require('test/test').run()" >> init.lua

CMD ["nvim", "--headless", "+qa!"]
