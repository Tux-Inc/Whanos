#!/bin/bash
printf "Installing kubetools"
./kubetools.sh
if [ $? -ne 0 ]; then
  printf "Installation of kubetools failed ❌"
  exit 1
fi
printf "Installation of kubetools completed successfully ✅"

printf "Installing docker registry"
./docker-registry.sh
if [ $? -ne 0 ]; then
  printf "Installation of docker registry failed ❌"
  exit 1
fi
printf "Installation of docker registry completed successfully ✅"

printf "Installing jenkins"
./jenkins.sh
if [ $? -ne 0 ]; then
  echo "Installation of jenkins failed ❌"
  exit 1
fi
printf "Installation of jenkins completed successfully ✅"

printf "INSTALLATION COMPLETED SUCCESSFULLY ✅"
printf "\n\n\n\n\n"

printf "INSTALLATION SUMMARY\n"
printf "========INSTALLATION SUMMARY========\n"
./installation-summary.sh
if [ $? -ne 0 ]; then
  echo "Installation summary failed ❌"
  exit 1
fi
printf "====================================\n"
printf "Happy hacking! 🚀\n"

