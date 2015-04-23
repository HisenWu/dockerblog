```shell
server='Server Version 0.2.0'
reg='^Server Version [0-9]+\.[0-9]+\.[0-9]+$'

#server=' 0.2.5'
#reg='^a [0-9]+\.[0-9]+\.[0-9]+$'

if [[ "$server" =~ $reg ]]; then
        echo 'ok'
else
        echo 'no ok'
fi
```
