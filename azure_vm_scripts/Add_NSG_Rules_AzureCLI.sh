# Allow PostGreSQL connections
# NOTE: This is OPTIONAL! pgAdmin can connect over SSH! 
az network nsg rule create --resource-group $RESOURCE_GROUP_NAME \
--nsg-name "${VM_NAME}NSG" \
--name 'PostgreSQLInboundAllow' \
--protocol '*' \
--priority 1001 \
--destination-port-range 5432 \

# Open HTTP port 80
az network nsg rule create --resource-group $RESOURCE_GROUP_NAME \
--nsg-name "${VM_NAME}NSG" \
--name 'HTTPInboundAllow' \
--protocol '*' \
--priority 1002 \
--destination-port-range 80 \

# Open HTTPS port 443
az network nsg rule create --resource-group $RESOURCE_GROUP_NAME \
--nsg-name "${VM_NAME}NSG" \
--name 'SSLInboundAllow' \
--protocol tcp \
--priority 1003 \
--destination-port-range 443 \