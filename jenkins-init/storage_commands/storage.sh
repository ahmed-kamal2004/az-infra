git clone --single-branch --branch v1.15.6 https://github.com/rook/rook.git



kubectl create -f deploy/examples/crds.yaml -f deploy/examples/common.yaml -f deploy/examples/operator.yaml

kubectl create -f deploy/examples/cluster.yaml

kubectl -n rook-ceph get pod

kubectl create -f deploy/examples/toolbox.yaml