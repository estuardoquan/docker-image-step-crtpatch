# Crtpatch

Crtpatch is a simple docker container that renews smallstep certificates depending on the time (static/elapsed).

On previous versions of this image we would be running `crond` in foreground mode as the main `CMD`. 
However this proved to be an issue, `cron`/`crontab` need a privileged user to run and by running this under the `root` user, permissions for the `site.crt`/`site.key` pair were not compatible with the other services such as `php`, `node`; NOTE: `nginx` reverse proxies are SSL encrypted and work out of the box whether crt/key belong to root user or not since this service is being run as root; how ever this will cange in further versions, and `nginx` included in the aformentioned list

## Environement

The following are the required and available environement variables that are available to customize the certificate's information. This image can be run globally and per-project.

```
#
# Important files and their path
#
ROOTCRT=/var/local/step/root_ca.crt
SITECRT=/var/local/step/site.crt
SITEKEY=/var/local/step/site.key

#
# Certificate Name
#
STEP_INIT_NAME="LocalhostCrt"

#
# list of domain names to include in certificate. All subdomains added by default.
#
STEP_INIT_DNS="localhost"

#
# Certificate Authority data
#
STEP_CA_URL=https://localhost:5739
STEP_FINGERPRINT=
STEP_KID=

#
# Files to be included in the secrets runtime
#
STEP_PASSWORD_FILE=/run/secrets/password
STEP_PROVISIONER_PASSWORD_FILE=/run/secrets/provisioner_password

#
# Other
#

```


