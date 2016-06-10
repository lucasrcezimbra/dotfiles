function n(){
  if [ $1 ]; then
    nautilus $1 &
  else
    nautilus $PWD &
  fi
}
