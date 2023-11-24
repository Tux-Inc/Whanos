
# Execute detect_language.sh script
./detect_language.sh
if [ $? -ne 0 ]; then
  echo "detect_language.sh failed"
  exit 1
fi

# Get the output of detect_language.sh
language=$(./detect_language.sh)

# Execute build_image.sh script with the output of detect_language.sh as argument
./build_image.sh "$language"
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
