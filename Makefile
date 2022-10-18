nvim_unit := $(wildcard tests/nvim/unit/*/*_spec.lua)
nvim_integration := $(wildcard tests/nvim/integration/*/*_spec.lua)
nvim_functional := $(wildcard tests/nvim/functional/test_*.lua)
nvim_functional_plenary := $(wildcard tests/nvim/functional/*_spec.lua)

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
test_nvim_functional tests/nvim/functional : $(nvim_functional_plenary) $(nvim_functional)

NVIM := nvim
export VIM := $(shell VIM= VIMRUNTIME= $(NVIM) --headless -u NONE --cmd 'echo $$VIM | q' 2>&1)
export VIMRUNTIME := $(shell VIM= VIMRUNTIME= $(NVIM) --headless -u NONE --cmd 'echo $$VIMRUNTIME | q' 2>&1)
export MYVIMRC := tests/nvim/minimal_init.lua
export XDG_CONFIG_HOME := $(abspath .)
export XDG_DATA_HOME :=
export XDG_STATE_HOME := $(abspath tests/nvim/state)
export XDG_CACHE_HOME := $(abspath tests/nvim/cache)
export XDG_CONFIG_DIRS :=
export XDG_DATA_DIRS :=

unexport LUA_PATH LUA_CPATH

nvim_args := --headless -u $(MYVIMRC) --noplugins -n -i NONE

$(XDG_STATE_HOME) :
	mkdir "$(XDG_STATE_HOME)"

$(XDG_CACHE_HOME) :
	mkdir "$(XDG_CACHE_HOME)"

.PHONY : $(nvim_unit)
$(nvim_unit) : $(XDG_STATE_HOME) $(XDG_CACHE_HOME)
	$(NVIM) $(nvim_args) -c "lua require('plenary.busted').run('$@')"

.PHONY : $(nvim_integration)
$(nvim_integration) : $(XDG_STATE_HOME) $(XDG_CACHE_HOME)
	$(NVIM) $(nvim_args) -c "lua require('plenary.busted').run('$@')"

.PHONY : $(nvim_functional)
$(nvim_functional) : $(XDG_STATE_HOME) $(XDG_CACHE_HOME)
	$(NVIM) $(nvim_args) -c "lua require('mini.test').setup(); MiniTest.run_file('$@')"

.PHONY : $(nvim_functional_plenary)
$(nvim_functional_plenary) : $(XDG_STATE_HOME) $(XDG_CACHE_HOME)
	$(NVIM) --headless --clean -u nvim/init.lua -n --cmd "set rtp^=nvim" -c "lua require('plenary.busted').run('$@')"

.PHONY : clean
clean :
	rm -rfv "$(XDG_STATE_HOME)" "$(XDG_CACHE_HOME)"
