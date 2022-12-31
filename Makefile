nvim_unit_plenary := $(wildcard tests/nvim/unit/*_spec.lua tests/nvim/unit/*/*_spec.lua)
nvim_integration_plenary := $(wildcard tests/nvim/integration/*_spec.lua tests/nvim/integration/*/*_spec.lua)
nvim_integration_minitest := $(wildcard tests/nvim/integration/test_*.lua)
nvim_functional_plenary := $(wildcard tests/nvim/functional/*_spec.lua)
nvim_functional_minitest := $(wildcard tests/nvim/functional/test_*.lua tests/nvim/functional/*/test_*.lua)

.PHONY : update
update : update_vim_plugins

.PHONY : update
update_vim_plugins :
	packages/vim-plugins/update.sh

.PHONY : test
test : test_all

.PHONY : test_all
test_all : test_nvim test_nix

# Directories
test_home_dir := tests/.home
dirs test% : export HOME = $(abspath $(test_home_dir))
dirs test% : export XDG_CONFIG_HOME = $(abspath .)
dirs test% : export XDG_DATA_HOME = $(HOME)/.local/share
dirs test% : export XDG_STATE_HOME = $(HOME)/.local/state
dirs test% : export XDG_CACHE_HOME = $(HOME)/.cache
dirs test% : export XDG_CONFIG_DIRS =
dirs test% : export XDG_DATA_DIRS =

.PHONY : dirs
dirs : $(test_home_dir)

$(test_home_dir) :
	mkdir -p "$(HOME)"

.PHONY : test_nvim tests/nvim
test_nvim tests/nvim : test_nvim_unit test_nvim_integration test_nvim_functional

.PHONY : test_nvim_unit tests/nvim/unit
test_nvim_unit tests/nvim/unit : $(nvim_unit_plenary)

.PHONY : test_nvim_integration tests/nvim/integration
test_nvim_integration tests/nvim/integration : $(nvim_integration_plenary) $(nvim_integration_minitest)

.PHONY : test_nvim_functional tests/nvim/functional
test_nvim_functional tests/nvim/functional : $(nvim_functional_plenary) $(nvim_functional_minitest)

# Neovim
NVIM := nvim
export NVIMPATH := $(NVIM)
export VIM :=
export VIMRUNTIME :=
export NVIM_LOG_FILE :=
export MYVIMRC := tests/nvim/minimal_init.lua

unexport LUA_PATH LUA_CPATH

nvim_args := --headless -u $(MYVIMRC) --noplugins -n -i NONE

.PHONY : $(nvim_unit_plenary)
$(nvim_unit_plenary) : dirs
	$(NVIM) $(nvim_args) -c "lua require('plenary.busted').run('$@')"

.PHONY : $(nvim_integration_plenary)
$(nvim_integration_plenary) : dirs
	$(NVIM) $(nvim_args) -c "lua require('plenary.busted').run('$@')"

.PHONY : $(nvim_integration_minitest)
$(nvim_integration_minitest) : dirs
	$(NVIM) $(nvim_args) -c "lua require('mini.test').setup(); MiniTest.run_file('$@')"

.PHONY : $(nvim_functional_plenary)
$(nvim_functional_plenary) : dirs
	$(NVIM) --headless --clean -u nvim/init.lua -n --cmd "set rtp^=nvim" -c "lua require('plenary.busted').run('$@')"

.PHONY : $(nvim_functional_minitest)
$(nvim_functional_minitest) : dirs
	$(NVIM) $(nvim_args) -c "lua require('mini.test').setup(); MiniTest.run_file('$@')"

# Nix
.PHONY : test_nix tests/nix
test_nix tests/nix : tests/nix/test_profile.fish

.PHONY : tests/nix/test_profile.fish
tests/nix/test_profile.fish : dirs
	fish tests/nix/test_profile.fish

# Cleaning
.PHONY : clean
clean :
	rm -rfv tests/.home
