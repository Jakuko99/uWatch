# uWatch

Forked from [uWatch](https://gitlab.com/jiiho1/uwatch) by [Jiiho](https://gitlab.com/jiiho1) on GitLab.

Smartwatch Sync App for Ubuntu Touch

# Heads up

I am moving away from the gatttool backend. It is old and problematic to use.
In the latest build (2022-09-06) I moved to only bluetoothclt which let's me handle the connections and sending/receiving of data better.

Currently the only versions of Ubuntu Touch supporting this, are those in the "Development" channel, as BlueZ was updated to version 5.53.

## Issues

It seems Ubuntu Touch is not able to fetch all GATT services/attributes. Currently the battery service is not available so the battery level can't be read.
