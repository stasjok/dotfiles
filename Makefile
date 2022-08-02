.PHONY : test
test : functional_test

.PHONY : functional_test
functional_test :
	nvim --headless --noplugin -u NORC -c \
	    "lua require('plenary.test_harness').test_directory('nvim/tests/functional')"
