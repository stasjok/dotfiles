nvim_unit_plenary := $(wildcard tests/nvim/unit/*_spec.lua tests/nvim/unit/*/*_spec.lua)
nvim_integration_plenary := $(wildcard tests/nvim/integration/*_spec.lua tests/nvim/integration/*/*_spec.lua)
nvim_integration_minitest := $(wildcard tests/nvim/integration/test_*.lua)
nvim_functional_plenary := $(wildcard tests/nvim/functional/*_spec.lua)
nvim_functional_minitest := $(wildcard tests/nvim/functional/test_*.lua tests/nvim/functional/*/test_*.lua)

.PHONY : test
test : test_all

.PHONY : test_all
test_all : test_nvim test_nix

.PHONY : test_nvim tests/nvim
test_nvim tests/nvim : test_nvim_unit test_nvim_integration test_nvim_functional

.PHONY : test_nvim_unit tests/nvim/unit
test_nvim_unit tests/nvim/unit : $(nvim_unit_plenary)

.PHONY : test_nvim_integration tests/nvim/integration
test_nvim_integration tests/nvim/integration : $(nvim_integration_plenary) $(nvim_integration_minitest)

.PHONY : test_nvim_functional tests/nvim/functional
test_nvim_functional tests/nvim/functional : $(nvim_functional_plenary) $(nvim_functional_minitest)

export XDG_CONFIG_HOME := $(abspath .)
export XDG_DATA_HOME :=
export XDG_STATE_HOME := $(abspath tests/.state)
export XDG_CACHE_HOME := $(abspath tests/.cache)
export XDG_CONFIG_DIRS :=
export XDG_DATA_DIRS :=
export TMPDIR := $(abspath tests/.tmp)

$(XDG_STATE_HOME) :
	mkdir -p "$(XDG_STATE_HOME)/nvim"

$(XDG_CACHE_HOME) :
	mkdir -p "$(XDG_CACHE_HOME)/nvim"

$(TMPDIR) :
	mkdir -p "$(TMPDIR)"

NVIM := nvim
export NVIMPATH := $(NVIM)
export VIM :=
export VIMRUNTIME :=
export NVIM_LOG_FILE :=
export MYVIMRC := tests/nvim/minimal_init.lua

unexport LUA_PATH LUA_CPATH

nvim_args := --headless -u $(MYVIMRC) --noplugins -n -i NONE

.PHONY : $(nvim_unit_plenary)
$(nvim_unit_plenary) : $(XDG_STATE_HOME) $(XDG_CACHE_HOME) $(TMPDIR)
	$(NVIM) $(nvim_args) -c "lua require('plenary.busted').run('$@')"

.PHONY : $(nvim_integration_plenary)
$(nvim_integration_plenary) : $(XDG_STATE_HOME) $(XDG_CACHE_HOME) $(TMPDIR)
	$(NVIM) $(nvim_args) -c "lua require('plenary.busted').run('$@')"

.PHONY : $(nvim_integration_minitest)
$(nvim_integration_minitest) : $(XDG_STATE_HOME) $(XDG_CACHE_HOME) $(TMPDIR)
	$(NVIM) $(nvim_args) -c "lua require('mini.test').setup(); MiniTest.run_file('$@')"

.PHONY : $(nvim_functional_plenary)
$(nvim_functional_plenary) : $(XDG_STATE_HOME) $(XDG_CACHE_HOME) $(TMPDIR)
	$(NVIM) --headless --clean -u nvim/init.lua -n --cmd "set rtp^=nvim" -c "lua require('plenary.busted').run('$@')"

.PHONY : $(nvim_functional_minitest)
$(nvim_functional_minitest) : $(XDG_STATE_HOME) $(XDG_CACHE_HOME) $(TMPDIR)
	$(NVIM) $(nvim_args) -c "lua require('mini.test').setup(); MiniTest.run_file('$@')"

.PHONY : test_nix tests/nix
test_nix tests/nix : tests/nix/test_profile.fish

.PHONY : tests/nix/test_profile.fish
tests/nix/test_profile.fish :
ifdef FROM_NIX
	fish tests/nix/test_profile.fish
else
	nix shell .#default -c fish tests/nix/test_profile.fish
endif

.PHONY : clean
clean :
	rm -rfv "$(XDG_STATE_HOME)" "$(XDG_CACHE_HOME)" "$(TMPDIR)"
