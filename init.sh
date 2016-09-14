#!/bin/sh


if [ -n "$CFG" ]
then
  echo "$CFG" > /etc/git2consul.d/config.json
fi

#echo "REPO: $GIT_REPO"
sed -i -e "s|GIT_REPO|$GIT_REPO|" /etc/git2consul.d/config.json
#cat /etc/git2consul.d/config.json
sed -i -e "s|NAMESPACE|$NAMESPACE|" /etc/git2consul.d/config.json
#cat /etc/git2consul.d/config.json
sed -i -e "s|GIT_SOURCEROOT|$GIT_SOURCEROOT|" /etc/git2consul.d/config.json

if [ -n "$IDENC" ]
then
  ID=$(echo $IDENC |base64 -d)
  IDPUB=$(echo $IDPUBENC |base64 -d)
fi

if [ -n "$ID" ]
then
  echo "Adding SSH Keys to agent"
  mkdir ~/.ssh
#  echo $ID   |base64 -d > ~/.ssh/id_rsa
#  echo $IDPUB|base64 -d > ~/.ssh/id_rsa.pub
  echo $ID   > ~/.ssh/id_rsa
  echo $IDPUB > ~/.ssh/id_rsa.pub
  echo -e "StrictHostKeyChecking no\nUserKnownHostsFile=/dev/null" > ~/.ssh/config
  chmod 700 -R ~/.ssh
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa
  ssh-add -l
fi
echo -e "$(date) starting git2consul. found these env vars: \nCFG:$CFG \nGIT_REPO:$GIT_REPO \nIDPUB:$IDPUB \nCONSUL_ENDPOINT:$CONSUL_ENDPOINT \nCONSUL_PORT:$CONSUL_PORT"
#cat /etc/git2consul.d/config.json
# 
exec /usr/bin/node /usr/lib/node_modules/git2consul  --config-file /etc/git2consul.d/config.json $@

