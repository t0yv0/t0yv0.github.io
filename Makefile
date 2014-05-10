.PHONY: main

main:
	cabal configure --enable-tests && cabal build && cabal test

deploy:
        git remote add live git@github.com:t0yv0/t0yv0.github.io.git
	git add .
	git commit -am 'CI build'
	git push -u live master
