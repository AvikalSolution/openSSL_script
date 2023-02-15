#!/usr/bin/env zsh
#cd non_production_cert
mkdir sign_verify
cp ./non_production_cert/*.pem ./sign_verify
#find ./non_production_cert -name "*.pem" | xargs cp -t ./sign_verify 
cp ./non_production_cert/identity.key ./sign_verify
#find ./non_production_cert -name "identity.key" | xargs cp -t ./sign_verify 
cd sign_verify
echo "This is data file" > data.txt
openssl rsa -in identity.key -pubout -out public.key
openssl dgst -sha256 -sign identity.key -out  data.txt.sig data.txt
echo "--------verifying certificate chain--------"
openssl verify -x509_strict -CAfile root.pem -untrusted intermediate.pem identity.pem
echo "--------verifying signature--------"
openssl dgst -sha256 -verify public.key -signature data.txt.sig data.txt

#sudo chmod u+x ./sign_verify.sh
#---for pkcs#7-----
##p7b to pem
#openssl pkcs7 -inform der -print_certs -in cad.p7b -out certificate.pem
##chain verification + signature verification
#openssl smime -verify -inform der -in file1.txt.sig -content file1.txt -certfile leaf.pem -CAfile certificate.pem
##choose the -noverify to ignore chain verification
