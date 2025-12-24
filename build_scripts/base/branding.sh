#!/usr/bin/env bash

set -xeuo pipefail

IMAGE_REF="ostree-image-signed:docker://ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}"
IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_FLAVOR="main"
IMAGE_TAG="nightly"

cat >$IMAGE_INFO <<EOF
{
  "image-name": "${IMAGE_NAME}",
  "image-ref": "${IMAGE_REF}",
  "image-flavor": "${IMAGE_FLAVOR}",
  "image-vendor": "${IMAGE_VENDOR}",
  "image-tag": "${IMAGE_TAG}",
}
EOF

IMAGE_PRETTY_NAME="Bluefin Distroless"
HOME_URL="https://projectbluefin.io"
DOCUMENTATION_URL="https://docs.projectbluefin.io"
SUPPORT_URL="https://github.com/projectbluefin/distroless/issues"
BUG_SUPPORT_URL="https://github.com/projectbluefin/distroless/issues"
CODE_NAME="Dakotaraptor"
ID="bluefin-distroless"

# OS Release File (changed in order with upstream)
sed -i -f - /usr/lib/os-release <<EOF
    s/^NAME=.*/NAME="${IMAGE_PRETTY_NAME}"/
    s/^ID=.*/ID="${ID}"/
    s/^PRETTY_NAME=.*/PRETTY_NAME="${IMAGE_PRETTY_NAME}"/
    s|^BUG_REPORT_URL=.*|BUG_REPORT_URL="${BUG_SUPPORT_URL}"|
    s|^HOME_URL=.*|HOME_URL="${HOME_URL}"|
    /^VERSION_CODENAME=/d
    /^VERSION_ID=.*/a VERSION_CODENAME="${CODE_NAME}"
    /^IMAGE_VERSION=/d
    /^SYSEXT_LEVEL=/d
    /^GNOMEOS_COMMIT=/d
    /^GNOMEOS_COMMIT_DATE=/d
    /^GNOMEOS_COMMITS_URL=/d
EOF

# Extra file content
cat >> /usr/lib/os-release <<EOF
DOCUMENTATION_URL="${DOCUMENTATION_URL}"
SUPPORT_URL="${SUPPORT_URL}"
LOGO=img-logo-icon
DEFAULT_HOSTNAME="bluefin"
EOF

# Weekly user count for fastfetch
curl --retry 3 https://raw.githubusercontent.com/ublue-os/countme/main/badge-endpoints/bluefin.json | jq -r ".message" > /usr/share/ublue-os/fastfetch-user-count

# bazaar weekly downloads used for fastfetch
curl -X 'GET' \
'https://flathub.org/api/v2/stats/io.github.kolunmi.Bazaar?all=false&days=1' \
-H 'accept: application/json' | jq -r ".installs_last_7_days" | numfmt --to=si --round=nearest > /usr/share/ublue-os/bazaar-install-count