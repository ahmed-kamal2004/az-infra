commit(){
    git add .;
    git commit -m$1;
    git push;
}


commit $1