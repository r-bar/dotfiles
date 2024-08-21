#echo "TOP OF ZSHRC\n$PATH"
ZSHRC_BENCHMARK=0

for file in $HOME/.zshrc.d/*.zsh; do 
  if [ $ZSHRC_BENCHMARK -eq 1 ]; then start=$(date +%s.%N); fi
  source $file
  if [ $ZSHRC_BENCHMARK -eq 1 ]; then
    stop=$(date +%s.%N)
    echo "$(($stop - $start))\t$file"
  fi
done
export LD_LIBRARY_PATH=/home/ryan/.local/lib/arch-mojo:$LD_LIBRARY_PATH
