# Terraform Azure Database for PostgreSQL - Flexible Server

Sample terraform to create an Azure PostgreSQL Flexible Server in a private network, without public IP. \
A virtual machine will be created in order to access to the database.

[Flexible Server documentation](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/)

[Networking overview for Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking#virtual-network-concepts)

>>> Your flexible server must be in a subnet that's _delegated_. That is, only Azure Database for PostgreSQL - Flexible Server instances can use that subnet. \
The smallest CIDR range you can specify for a subnet is /28, which provides fourteen IP addresses, however the first and last address in any network or subnet can't be assigned to any individual host. Azure reserves five IPs to be utilized internally by Azure networking, which include two IPs that cannot be assigned to host, mentioned above. This leaves you eleven available IP addresses for /28 CIDR range, whereas a single Flexible Server with High Availability features utilizes 4 addresses.

# Test connection from VM

```bash
ssh <vm user>@$<vm_public_ip> 'psql "host=<pgsql_name>.postgres.database.azure.com port=5432 dbname=<db_name> user=<pgsql_login> sslmode=require" -c "select version();"'
```

# Test connection from AKS

```bash
$ kubectl run pgsql-client --image=alpine:3.17.3 --restart=Never --command sleep infinity
```

in another terminal

```bash
$ kubectl exec -it pgsql-client -- sh
/ # apk --no-cache add postgresql13-client

/ # psql "host=<pgsql_name>.postgres.database.azure.com port=5432 dbname=<db_name> user=<pgsql_login> sslmode=require" -c "select version();"
```