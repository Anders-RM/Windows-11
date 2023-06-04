#set up ssh key for github assking for passphrase
ssh-keygen -t rsa -b 4096 -C "Main Key" -f ~/.ssh/id_rsa -N '' -q   #create ssh key

#insatlling git and setting up git in windows using winget
winget install git -e
git config --global user.name "Anders-RM"
git config --global user.email "Anders_RMathiesen@pm.me"
git config --global core.editor "code --wait"

#installing vscode using winget
winget install vscode -e

#installing python using winget
winget install python -e

#running python.py script
python python.py
