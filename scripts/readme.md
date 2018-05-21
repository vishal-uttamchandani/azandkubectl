After creating bash script file on windows. Copy the files to linux machine and 
run following:

```
sed -i -e 's/\r$//' cleanup.sh
```

This will remove the "bad interpreter" error.