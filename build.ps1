function clearPath($x) {
    if (Test-Path $x) {
        rm -r $x
    }
}

function cleanFiles() {
    echo '==> cleaning..'
    clearPath _cache
    clearPath _site
    clearPath css
    clearPath site.hi
    clearPath site.o
    clearPath index.html
    clearPath atom.xml
    clearPath about.html
    clearPath archive.html
    rm posts/*.html
    clearPath site.exe
}

function buildSite() {
    echo '==> building..'
    ghc --make -threaded site.hs
    ./site.exe build
    cp _site/posts/*.html posts/
    cp _site/*.html ./
    cp _site/*.xml ./
    clearPath css
    cp -r _site/css css
}

if ($args[0] -eq 'clean') {
    cleanFiles
} elseif ($args[0] -eq 'site') {
    buildSite
} elseif ($args[0] -eq 'watch') {
    buildSite
    ./site.exe watch
} else {
    cleanFiles
    buildSite
}
