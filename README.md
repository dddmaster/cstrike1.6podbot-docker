# cstrike1.6podbot-docker
Fork of https://github.com/archont94/counter-strike1.6 with custom modifications

## changes
- removed fast download (debloat)
- added yapb bot
- added version arguments for metamod, amxmodx, yapb
- added **optional** argument for mapcycle auto creation

## todo
- cleanup github actions
- cleanup args and envs
- setup healthcheck and testing
- write documentation

## examples
!!! insecure for local testing only !!!
```
docker run --network host --rm dddmaster/cstrike:yapb.amxmodx
```