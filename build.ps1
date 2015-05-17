function clearPath($x) {
    if (Test-Path $x) {
        rm -r $x
    }
}

function cleanFiles() {
    echo 'cleaning..'
    clearPath _cache
    clearPath _site
    clearPath site.exe
    clearPath site.hi
    clearPath site.o
}

if ($args[0] -eq 'clean') {
    cleanFiles
} else {
    ghc --make -threaded site.hs
}
