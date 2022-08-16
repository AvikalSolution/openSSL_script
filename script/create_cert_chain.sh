#!/usr/bin/env bash

mkdir non_production_cert
cd non_production_cert
mkdir root_db
mkdir intermediate_db

echo 01 > intermediate_db/serial
echo 01 > root_db/serial

touch root_db/index intermediate_db/index

openssl genrsa -out root.key 2048
openssl genrsa -out intermediate.key 2048
openssl genrsa -out identity.key 2048

# echo -n "Enter default Country Name (2 letter code): "
# read country_name

# echo -n "Enter default State or Province Name: "
# read state_name

# echo -n "Enter default Locality Name: "
# read locality_name

# echo -n "Enter default Organization Name: "
# read org_name

# echo -n "Enter default Organizational Unit Name: "
# read org_unit_name

# echo -n "Enter default Email Address: "
# read email_address

cat> required_identity_param.cnf << EOF
[ req ]
distinguished_name = req_distinguished_name
prompt             = no

[ req_distinguished_name ]
countryName = IN
commonName  = avikal_identity
EOF

cat> required_intermediate_param.cnf << EOF
[ req ]
distinguished_name = req_distinguished_name
prompt             = no

[ req_distinguished_name ]
countryName = IN
commonName  = avikal_intermediate_identity
EOF

cat> required_root_param.cnf << EOF
[ req ]
distinguished_name = req_distinguished_name
prompt             = no

[ req_distinguished_name ]
countryName = IN
commonName  = avikal_root_CA
EOF

openssl req -new -key root.key -out root.csr -config required_root_param.cnf
openssl req -new -key intermediate.key -out intermediate.csr -config required_intermediate_param.cnf
openssl req -new -key identity.key -out identity.csr -config required_identity_param.cnf

echo "passed 1"

cat > root.cnf << EOF
[ ca ]
default_ca      = CA_default

[ CA_default ]
dir             = ./root_db
database        = \$dir/index
new_certs_dir   = ./
certificate     = ./root.pem
serial          = \$dir/serial
private_key     = ./root.key

policy          = policy_any
email_in_dn     = no
unique_subject  = no
copy_extensions = none
default_md      = sha256

[ policy_any ]
countryName            = optional
stateOrProvinceName    = optional
organizationName       = optional
organizationalUnitName = optional
commonName             = supplied
EOF

cat > ca.ext << EOF
[ default ]
basicConstraints = critical,CA:true
keyUsage         = critical,keyCertSign
EOF
openssl ca -in root.csr -out root.pem -config root.cnf -selfsign -extfile ca.ext -days 1086

echo "passed 2"

cat > intermediate.cnf << EOF
[ ca ]
default_ca      = CA_default

[ CA_default ]
dir             = ./intermediate_db
database        = \$dir/index
new_certs_dir   = ./
certificate     = ./intermediate.pem
serial          = \$dir/serial
private_key     = ./intermediate.key

policy          = policy_any
email_in_dn     = no
unique_subject  = no
copy_extensions = none
default_md      = sha256

[ policy_any ]
countryName            = optional
stateOrProvinceName    = optional
organizationName       = optional
organizationalUnitName = optional
commonName             = supplied
EOF

echo "passed 3"
openssl ca -in intermediate.csr -out ./intermediate.pem -config root.cnf -extfile ca.ext -days 1000
openssl ca -in identity.csr -out ./identity.pem -config intermediate.cnf -days 365

echo "end"

#sudo chmod u+x ./create_cert_chain.sh