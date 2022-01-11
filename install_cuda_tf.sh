
# Installing Tensorflow, CUDA

OS=ubuntu2004
wget https://developer.download.nvidia.com/compute/cuda/repos/${OS}/x86_64/cuda-${OS}.pin 
sudo mv cuda-${OS}.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/${OS}/x86_64/7fa2af80.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/${OS}/x86_64/ /"

wget https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64/nvidia-machine-learning-repo-ubuntu2004_1.0.0-1_amd64.deb
sudo apt install ./nvidia-machine-learning-repo-ubuntu2004_1.0.0-1_amd64.deb

sudo apt-get update
sudo apt-get install --no-install-recommends -y python3 python3-pip cuda libcudnn8 libcudnn8-dev
python3 -m pip install tensorflow

