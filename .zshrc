for file in $HOME/.zshrc.d/*.zsh; do 
  #start=$(date +%s.%N)
  source $file
  #stop=$(date +%s.%N)
  #echo $file"\t"$(($stop - $start))
done
