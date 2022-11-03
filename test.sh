sudo docker run -it \
  -v $(pwd):/root/.config/nvim/pack/common/start/decl:ro \
  -v $(pwd)/test:/root/.config/nvim/test \
  decl-test
echo ''
