#set up ssh key for github assking for passphrase
ssh-keygen -t rsa -b 4096 -C "Main Key" -f $HOME\.ssh\id_rsa -N '' -q   #create ssh key

#insatlling git and setting up git in windows using winget
winget install git -e
git config --global user.name "Anders-RM"
git config --global user.email "Anders_RMathiesen@pm.me"
git config --global core.editor "code --wait"

#installing vscode using winget
winget install Microsoft.VisualStudioCode -e

#installing latest version of python downloading from python.org
Invoke-WebRequest https://www.python.org/ftp/python/3.11.3/python-3.11.3-amd64.exe -OutFile python.exe
./python.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

#running python.py script
python python.py