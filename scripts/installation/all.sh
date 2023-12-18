#!/bin/bash
printf "🏗️ Installing kubetools\n"
/Whanos/scripts/installation/kubetools.sh
if [ $? -ne 0 ]; then
  printf "❌ Installation of kubetools failed\n"
  exit 1
fi
printf "\n\n\n✅ Installation of kubetools completed successfully\n\n\n"

printf "🏗️ Installing docker registry\n"
/Whanos/scripts/installation/docker-registry.sh
if [ $? -ne 0 ]; then
  printf "❌ Installation of docker registry failed\n"
  exit 1
fi
printf "\n\n\n✅ Installation of docker registry completed successfully\n"

printf "🏗️ Installing jenkins\n"
/Whanos/scripts/installation/jenkins.sh
if [ $? -ne 0 ]; then
  echo "❌ Installation of jenkins failed\n"
  exit 1
fi
printf "\n\n\n✅ Installation of jenkins completed successfully\n"

printf "\n\n\nINSTALLATION COMPLETED SUCCESSFULLY\n"
printf "\n\n\n\n\n"

printf "========INSTALLATION SUMMARY========\n"
/Whanos/scripts/installation/installation-summary.sh
if [ $? -ne 0 ]; then
  echo "❌ Installation summary failed\n"
  exit 1
fi
printf "====================================\n"
printf "Happy hacking! 🚀\n"

