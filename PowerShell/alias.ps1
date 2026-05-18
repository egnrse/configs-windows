# some custom alias
# (by egnrse)

Set-Alias lsa ls


# using functions for aliases with arguments
function gits { git status }
function updateall { winget update --all --include-unknown --silent --accept-package-agreements --accept-source-agreements }
