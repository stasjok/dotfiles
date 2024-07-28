.PHONY : build
build :
	home-manager build --flake .

.PHONY : install
install :
	home-manager switch --flake .

.PHONY : shell
shell :
	nix develop -i -k TERM

.PHONY : update
update : update_flake

.PHONY : update_flake
update_flake :
	nix flake update

.PHONY : update_neovim
update_neovim :
	nix flake lock --update-input neovim

# Tests
.PHONY : test
test : test_all

# List of tests
nvim_unit_tests ::= $(wildcard tests/nvim/unit/*_spec.lua tests/nvim/unit/*/*_spec.lua)
nvim_integration_tests ::= $(wildcard tests/nvim/integration/test_*.lua) \
	$(wildcard tests/nvim/integration/*_spec.lua tests/nvim/integration/*/*_spec.lua)
nvim_functional_tests ::= $(wildcard tests/nvim/functional/*_spec.lua) \
	$(wildcard tests/nvim/functional/test_*.lua tests/nvim/functional/*/test_*.lua)
nvim_all_tests ::= test_nvim tests/nvim \
	test_nvim_unit tests/nvim/unit $(nvim_unit_tests) \
	test_nvim_integration tests/nvim/integration $(nvim_integration_tests) \
	test_nvim_functional tests/nvim/functional $(nvim_functional_tests)
all_tests ::= test_all $(nvim_all_tests)

.PHONY : $(all_tests)

# Run the same target in nix shell
ifndef NIX_BUILD_TOP
$(all_tests) :
	@nix develop -i -k TERM .#tests -c $(MAKE) $@
else
test_all : test_nvim

# Neovim
nvim_args ::= --headless -u tests/nvim/minimal_init.lua --noplugin -n -i NONE

test_nvim tests/nvim : test_nvim_unit test_nvim_integration test_nvim_functional
test_nvim_unit tests/nvim/unit : $(nvim_unit_tests)
test_nvim_integration tests/nvim/integration : $(nvim_integration_tests)
test_nvim_functional tests/nvim/functional : $(nvim_functional_tests)

$(nvim_unit_tests) $(nvim_integration_tests) $(nvim_functional_tests) :
	@nvim $(nvim_args) -c "lua require('mini.test').setup(); MiniTest.run_file('$@')"
endif

# Cleaning
.PHONY : clean
clean :
	rm -rfv tests/.home
