# Copy origin to temporary workspace.
Set-Location origin
git clean -xdn
Set-Location ..
robocopy origin .tmp /e

# Overrides files from ja directory.
robocopy aio-ja/ .tmp/aio /e

# Build angular.io
Set-Location .tmp
yarn install --frozen-lockfile --non-interactive
Set-Location aio
yarn build

Set-Location ../../

# Copy robots.txt
robocopy aio-ja/src/robots.txt .tmp/aio/dist/ /is

# Modify sitemap
((Get-Content -path .tmp/aio/dist/generated/sitemap.xml -Raw) -replace 'angular.io','angular-ja') | Set-Content -Path .tmp/aio/dist/generated/sitemap.xml