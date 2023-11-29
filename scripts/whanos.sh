DISPLAY_NAME=$1
echo "DISPLAY_NAME: $DISPLAY_NAME"

# Install docker-cli
./install_dockercli.sh
if [ $? -ne 0 ]; then
  echo "install_dockercli.sh failed"
  exit 1
fi

# Execute detect_language.sh script
./detect_language.sh
if [ $? -ne 0 ]; then
  echo "detect_language.sh failed"
  exit 1
fi

# Get the output of detect_language.sh
language=$(./detect_language.sh)

# Execute build_image.sh script with the output of detect_language.sh as argument
./build_image.sh "$language" "$DISPLAY_NAME"
if [ $? -ne 0 ]; then
  echo "build_image.sh failed"
  exit 1
fi

# Execute deploy_image.sh script
./deploy_image.sh
if [ $? -ne 0 ]; then
  echo "deploy_image.sh failed"
  exit 1
fi

# Return 0 if all scripts executed successfully
exit 0
