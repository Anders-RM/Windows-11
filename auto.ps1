#set up ssh key for github
ssh-keygen -t rsa -b 4096 -C "Main Key" -f $HOME\.ssh\id_rsa -N '@Ndersraeder' -q   #create ssh key

#insatlling git and setting up git in windows using winget
winget install Git.Git -e
git config --global user.name "Anders-RM"
git config --global user.email "Anders_RMathiesen@pm.me"
git config --global core.editor "code --wait"

#installing vscode using winget
winget install Microsoft.VisualStudioCode -e

#installing python version 3.11.3 downloading from python.org
Invoke-WebRequest https://www.python.org/ftp/python/3.11.3/python-3.11.3-amd64.exe -OutFile python.exe
./python.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

#run a comand as admin
Start-Process powershell -Verb runAs -ArgumentList 'iwr -useb https://christitus.com/win | iex'

#installing requests module
python -m pip install requests  

#running python.py script
python python.py