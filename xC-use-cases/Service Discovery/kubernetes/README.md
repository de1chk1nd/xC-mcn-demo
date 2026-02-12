[Service Discovery - Architecture]: https://community.f5.com/kb/technicalarticles/kubernetes-architecture-options-with-f5-distributed-cloud-services/306550
[Service Discovery - kubeconfig]: https://community.f5.com/kb/technicalarticles/service-discovery-and-authentication-options-for-kubernetes-providers-eks-aks-gc/297576
[Service Discovery - k8s RBAC]: https://community.f5.com/kb/technicalarticles/using-a-kubernetes-serviceaccount-for-service-discovery-with-f5-distributed-clou/300225

# Service Discovery - k8s
In this lab we'll create a basic k8s service discovery for a minikube "cluster" and route to k8s PODs/Services.

&nbsp;

***Overview:***

![Use Case - Service Discovery k8s](../../../docs/images/use-cases/SD-k8s.png)

&nbsp;

- ***Further Reading:***
    | Device                    	 		    | Notes                                                     |
    |:------------------------------------------|:----------------------------------------------------------|
    | [Service Discovery - Architecture]        | General k8s Options - focus on ***Secure k8s Gateway***   |
    | [Service Discovery - kubeconfig]          | HowTo create kubeconfig (Cloud Provider)                  |
    | [Service Discovery - k8s RBAC]            | Create kubeconfig with RBAC                               |

&nbsp;

## Create Service Discovery + Pools + Loadbalancer
```shell
"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/bin/setup.sh"
```

&nbsp;

## DELETE Service Discovery + Pools + Loadbalancer
```shell
"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/bin/delete.sh"
```