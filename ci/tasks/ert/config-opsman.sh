#!/bin/bash
set -e

sudo cp tool-om/om-linux /usr/local/bin

#Configure Opsman
om-linux --target https://opsmgr.$pcf_ert_domain -k \
     configure-authentication \
       --username "$pcf_opsman_admin" \
       --password "$pcf_opsman_admin_passwd" \
       --decryption-passphrase "$pcf_opsman_admin_passwd"