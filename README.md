# image_uploader

Flutter project that demonstrate use of amplify to upload image in s3.

### Install amplify cli using:
1. npm install -g @aws-amplify/cli (or)
2. curl -sL https://aws-amplify.github.io/amplify-cli/install | bash && $SHELL (MAC or Linux)
3. curl -sL https://aws-amplify.github.io/amplify-cli/install-win -o install.cmd && install.cmd (Windows)

### Initialize amplify
Type following command at root of your flutter project:
sudo amplify init

### Provision backend storage
sudo amplify add storage

### Push changes to cloud
amplify push
