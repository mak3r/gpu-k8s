# Images for demo
## Default CUDA image(s) - run `nvidia-smi` in the container to see the gpu stats
nvidia/cuda:9.0-base
## Simple container with a cuda demo app - run `./vectorAdd` inside the container pass a whole number argument to indicate how many vectors to add
mak3r/cuda-vector-add:demo-007
## Simple job container - Docker command in container is ./vectorAdd. It will use the default number of vectors to add - run it as a cron job
mak3r/cuda-vector-add:job002
## Run vector add as just a pod by loading `vector-add.yml` in the rancher deployment page or use kubectl
`kubectl create -f https://raw.githubusercontent.com/mak3r/gpu-k8s/master/vector-add.yml`
