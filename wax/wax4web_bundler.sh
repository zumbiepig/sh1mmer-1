#!/usr/bin/env bash

rm -f ../wax4web/wax4web.tar ../wax4web/wax4web.tar.zip
tar -cvf ../wax4web/wax4web.tar wax4web_entry.sh wax.sh str1pper.sh bootstrap sh1mmer_legacy sh1mmer_bw payloads firmware lib/wax_common.sh lib/shflags lib/bin/i386/cgpt --owner=0 --group=0
cd ../wax4web
zip wax4web.tar.zip wax4web.tar
rm wax4web.tar
