sudo docker run -it --network none \
  -v $(pwd)/lua:/root/.config/nvim/pack/common/start/decl/lua:ro \
  -v $(pwd)/plugin:/root/.config/nvim/pack/common/start/decl/plugin:ro \
  -v $(pwd)/test:/root/.config/nvim/test \
  decl-test
echo ''
