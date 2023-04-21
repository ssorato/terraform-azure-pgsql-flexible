# Terraform Azure Database for PostgreSQL - Flexible Server

Sample terraform to create an Azure PostgreSQL Flexible Server in a private network, without public IP. \
A virtual machine will be created in order to access to the database.

[Flexible Server documentation](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/)

[Networking overview for Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking#virtual-network-concepts)

>>> Your flexible server must be in a subnet that's _delegated_. That is, only Azure Database for PostgreSQL - Flexible Server instances can use that subnet. \
The smallest CIDR range you can specify for a subnet is /28, which provides fourteen IP addresses, however the first and last address in any network or subnet can't be assigned to any individual host. Azure reserves five IPs to be utilized internally by Azure networking, which include two IPs that cannot be assigned to host, mentioned above. This leaves you eleven available IP addresses for /28 CIDR range, whereas a single Flexible Server with High Availability features utilizes 4 addresses.
