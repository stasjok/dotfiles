nvim_functional := $(wildcard tests/nvim/functional/*_spec.lua)

.PHONY : test
test : test_all

.PHONY : test_all
test_all : test_nvim

.PHONY : test_nvim tests/nvim
test_nvim tests/nvim : test_nvim_functional

.PHONY : test_nvim_functional tests/nvim/functional
test_nvim_functional tests/nvim/functional : $(nvim_functional)

.PHONY : $(nvim_functional)
$(nvim_functional) :
	nvim --headless -c "lua require('plenary.busted').run('$@')"
