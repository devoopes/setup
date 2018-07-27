#bin/bash/
echo "Install Brew First"
pause

brew install python
curl https://bootstrap.pypa.io/get-pip.py -o ~/Downloads/get-pip.py
python ~/Downloads/get-pip.py --user

pip install virtualenv virtualenvwrapper --user
source /Users/$USER/Library/Python/2.7/bin/virtualenvwrapper.sh

cat ~/.virtualenvs/postactivate << EOF

project_name=$(basename $VIRTUAL_ENV)
GIT_REPOS="~/path/to/projects"
cd ${GIT_REPOS}/$project_name
if  [ -f requirements.txt ]; then
    pip install -r requirements.txt
elif [[ -d requirements && -f requirements/development.txt ]]; then
    pip install -r requirements/development.txt
fi
EOF
