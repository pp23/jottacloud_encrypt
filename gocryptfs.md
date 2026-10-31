# GoCryptFS File Backup

* Create an encrypted view of the directory to backup:
  ```
  gocryptfs -init -reverse data/
  # mount the plain data as encrypted folder
  gocryptfs -reverse data/ data.crypt/
  ```
  >**Store the masterkey securely and forever!**

* Read the encrypted folder as plain data:
  ```
  gocryptfs data.crypt/ data/
  ```

* Restore data with the master key (gocryptfs.conf not required):
  ```
  gocryptfs -aessiv -masterkey=<masterkey> data.crypt/ data/
  ```

* Restore data with master key without gocryptfs.conf and missing gocryptfs.diriv:
  ```
  # create a dummy gocryptfs.diriv file in the encrypted folder
  dd if=/dev/urandom of=data.crypt/gocryptfs.diriv bs=16 count=1
  # mount the folder with the master key
  gocryptfs -aessiv -masterkey=<masterkey> data.crypt/ data/
  # create a dummy file in the plain folder
  touch data/dummy.txt
  # rename the encrypted file to restore to the dummy encrypted file
  mv data.crypt/xEazDomYo0437EF244O4fG4N2kpPuAtmw4zgTycimVg data.crypt/1n4XC5Nt6V_iUPgGBhlFdA
  # the plain dummy file is now the restored file in plaintext
  ```
