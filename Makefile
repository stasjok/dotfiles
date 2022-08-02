.PHONY : test
test : nvim_test

.PHONY : nvim_test
nvim_test : nvim_functional_test

.PHONY : nvim_functional_test
nvim_functional_test :
	nvim --headless --noplugin -u NORC -c \
	    "lua require('plenary.test_harness').test_directory('nvim/tests/functional')"
