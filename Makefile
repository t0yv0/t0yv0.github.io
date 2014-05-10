.PHONY: main

main:
	cabal configure --enable-tests && cabal build && cabal test
