nvim_unit := $(wildcard tests/nvim/unit/*/*_spec.lua)
nvim_integration := $(wildcard tests/nvim/integration/*/*_spec.lua)
nvim_functional := $(wildcard tests/nvim/functional/*_spec.lua)

.PHONY : test
test : test_all

.PHONY : test_all
test_all : test_nvim

.PHONY : test_nvim tests/nvim
test_nvim tests/nvim : test_nvim_unit test_nvim_integration test_nvim_functional

.PHONY : test_nvim_unit tests/nvim/unit
test_nvim_unit tests/nvim/unit : $(nvim_unit)

.PHONY : test_nvim_integration tests/nvim/integration
test_nvim_integration tests/nvim/integration : $(nvim_integration)

.PHONY : test_nvim_functional tests/nvim/functional
test_nvim_functional tests/nvim/functional : $(nvim_functional)

.PHONY : $(nvim_unit)
$(nvim_unit) :
	nvim --headless -u NORC --noplugin -c "lua require('plenary.busted').run('$@')"

.PHONY : $(nvim_integration)
$(nvim_integration) :
	nvim --headless -u NORC --noplugin -c "lua require('plenary.busted').run('$@')"

.PHONY : $(nvim_functional)
$(nvim_functional) :
	nvim --headless -c "lua require('plenary.busted').run('$@')"
