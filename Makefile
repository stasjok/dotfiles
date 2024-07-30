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
nvim_tests ::= $(wildcard \
	tests/nvim/*_test.lua \
	tests/nvim/*/*_test.lua \
	tests/nvim/*/*/*_test.lua \
	tests/nvim/*/*/*/*_test.lua \
	)
nvim_all_tests ::= test_nvim tests/nvim $(nvim_tests)
all_tests ::= test_all $(nvim_all_tests)

.PHONY : $(all_tests)

# Run the same target in nix shell
ifndef NIX_BUILD_TOP
$(all_tests) :
	@nix develop -i -k TERM .#tests -c $(MAKE) $@
else
test_all : test_nvim

test_nvim tests/nvim :
	@nvim -l tests/nvim/runner.lua tests/nvim
# Separated tests
$(nvim_tests) :
	@nvim -l tests/nvim/runner.lua "$(@)"
endif

# Cleaning
.PHONY : clean
clean :
	rm -rfv tests/.home
