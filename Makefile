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
	tests/nvim/*/test_*.lua \
	tests/nvim/*/*_spec.lua \
	tests/nvim/*/*/test_*.lua \
	tests/nvim/*/*/*_spec.lua \
	tests/nvim/*/*/*/test_*.lua \
	tests/nvim/*/*/*/*_spec.lua \
	)
nvim_all_tests ::= test_nvim tests/nvim \
	test_nvim_unit tests/nvim/unit  \
	test_nvim_functional tests/nvim/functional \
	$(nvim_tests)
all_tests ::= test_all $(nvim_all_tests)

.PHONY : $(all_tests)

# Run the same target in nix shell
ifndef NIX_BUILD_TOP
$(all_tests) :
	@nix develop -i -k TERM .#tests -c $(MAKE) $@
else
test_all : test_nvim

test_nvim tests/nvim :
	@nvim -l tests/nvim/run.lua tests/nvim
test_nvim_unit tests/nvim/unit :
	@nvim -l tests/nvim/run.lua tests/nvim/unit
test_nvim_functional tests/nvim/functional :
	@nvim -l tests/nvim/run.lua tests/nvim/functional
# Separated tests
$(nvim_tests) :
	@nvim -l tests/nvim/run.lua "$(@)"
endif

# Cleaning
.PHONY : clean
clean :
	rm -rfv tests/.home
