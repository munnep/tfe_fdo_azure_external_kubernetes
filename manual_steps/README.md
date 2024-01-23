
# create a resource group

- Create a resource group where all the resources will fall under
![](media/20221105164701.png)    
![](media/20221105164714.png)    

- Create a network 
![](media/20221105164838.png)    
![](media/20221105165042.png)    
![](media/20221108092404.png)    
![](media/20221105165638.png)    
![](media/20221105165413.png)    
![](media/20221105165510.png)    
![](media/20221105165523.png)    
![](media/20221105165757.png)    
![](media/20221105165815.png)    

- create an network security group   
![](media/20221105171004.png)    
![](media/20221105171114.png)    
add some rules allow https, ssh and 8800 5432  
![](media/20221105173023.png)    
![](media/20221108093129.png)    




- create a NAT gateway   
![](media/20221105171257.png)    
![](media/20221105171326.png)   
![](media/20221105171421.png)    
![](media/20221105171441.png)    

- give all the subnets the network security group
![](media/20221105171724.png)    


- PostgreSQL Flex  
![](media/20221108093908.png)    
![](media/20221108094039.png)    
![](media/20221108094238.png)    
![](media/20221108094951.png)    
![](media/20221108095007.png)    
![](media/20221108095023.png)    

- After the database is create you need to change the following because of this article https://support.hashicorp.com/hc/en-us/articles/4548903433235-Terraform-Enterprise-External-Services-mode-with-Azure-Database-for-PostgreSQL-Flexible-Server-Failed-to-Initialize-**Plugins**
![](media/20221108103715.png)    
Select CITEXT, HSTORE, and UUID-OSSP  
![](media/20221108103911.png)  
Result should be    
![](media/20221108103849.png)    
![](media/20221108104017.png)    




- Storage account   
![](media/20221108095517.png)    
![](media/20221108095556.png)    
![](media/20221108103508.png)    
![](media/20221108103545.png)    
![](media/20221108103602.png)    
![](media/20221108103621.png)   
![](media/20221108104339.png)     
- create a container   
![](media/20221108103950.png)    
![](media/20221108104128.png)    

- Virtual machine   
![](media/20221108111017.png)    
![](media/20221108111334.png)    
![](media/20221108111423.png)    
![](media/20221108111513.png)    
![](media/20221108111540.png)    
![](media/20221108111552.png)    
![](media/20221108111615.png)    
![](media/20221108111653.png)    

- Make the DNS endpoint to this server in AWS console
![](media/20221108112137.png)    

- login to the virtual machine

```
ssh azureuser@52.233.240.242
```

On the machine execute the following

```
sudo systemctl stop apparmor
sudo systemctl disable apparmor

pushd /var/tmp
curl -o install.sh https://install.terraform.io/ptfe/stable
bash ./install.sh no-proxy private-address=10.233.1.4 public-address=52.233.240.242
```

- You will be prompted to go to the installation screen
![](media/20221108113116.png)   
![](media/20221108113202.png)    
![](media/20221108113242.png)    
![](media/20221108113440.png)    
- Go the the settings
![](media/20221108113700.png)    
![](media/20221108113752.png)    
![](media/20221108113918.png)    
![](media/20221108114537.png)    
![](media/20221108114610.png)    
![](media/20221108114624.png)  

- Try a test run in a workspace from directory test_code



### same steps except with a load balancer

- Loadbalancer in azure is called a application gateway
https://medium.com/@t.tak/build-https-support-load-balancer-on-azure-81e111e58d98

Application gateway requires extra ports to be opened
![](media/20221119094144.png)    

![](media/20221119094209.png)    
![](media/20221119094236.png)    
![](media/20221119094350.png)    
![](media/20221119094403.png)    
![](media/20221119094952.png)    
![](media/20221119095103.png)    
![](media/20221119095123.png)    
![](media/20221119095242.png)    
![](media/20221119095308.png)    
![](media/20221119095326.png)    
Er moet ook een correct health probe worden gemaakt    

![](media/20221119134143.png)  
![](media/20221119134214.png)    

On the machine execute the following

```
sudo systemctl stop apparmor
sudo systemctl disable apparmor

pushd /var/tmp
curl -o install.sh https://install.terraform.io/ptfe/stable
bash ./install.sh no-proxy private-address=10.233.11.4
```











certificates uit key vault

// pem to pfx - also password
openssl pkcs12 -export -out certificate.pfx -inkey private_key_pem -in server.crt










// pem to cer
openssl x509 -inform PEM -in fullchain.pem -outform DER -out certificate.cer