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
  echo "$ID"   > ~/.ssh/id_rsa_git2consul
  echo "$IDPUB" > ~/.ssh/id_rsa_git2consul.pub

  eval "$(ssh-agent -s)"
  chmod 600 -R ~/.ssh/id_rsa_git2consul
  ssh-add ~/.ssh/id_rsa_git2consul
  echo -e "StrictHostKeyChecking no\nUserKnownHostsFile=/dev/null" > ~/.ssh/config
  echo -e "Host git2consul\n\tIdentityFile ~/.ssh/id_rsa_git2consul" >> ~/.ssh/config
fi
echo -e "$(date) starting git2consul. found these env vars: \nCFG:$CFG \nGIT_REPO:$GIT_REPO \nIDPUB:$IDPUB \nCONSUL_ENDPOINT:$CONSUL_ENDPOINT \nCONSUL_PORT:$CONSUL_PORT"
#cat /etc/git2consul.d/config.json
# 
exec /usr/bin/node /usr/lib/node_modules/git2consul  --config-file /etc/git2consul.d/config.json $@


