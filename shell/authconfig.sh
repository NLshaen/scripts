#!/bin/bash

authconfig --winbindseparator=+ --winbindtemplatehomedir=/home/%U --winbindtemplateshell=/bin/bash --enablewinbindusedefaultdomain --enablewinbind --enablewinbindauth --smbrealm=NUTANIX.INDUS --smbidmapuid=600-2000 --smbidmapgid=600-2000 --update
