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
update : update_flake update_vim_plugins

.PHONY : update_flake
update_flake :
	nix flake update

.PHONY : update_vim_plugins
update_vim_plugins :
	packages/vim-plugins/update.sh

.PHONY : test
test : test_all

.PHONY : test_all
test_all : test_nvim

.PHONY : test_nvim tests/nvim
test_nvim tests/nvim : test_nvim_unit test_nvim_integration test_nvim_functional

.PHONY : test_nvim_unit tests/nvim/unit
test_nvim_unit tests/nvim/unit :
	nix build --no-link -L .#checks.x86_64-linux.nvim-unit

.PHONY : test_nvim_integration tests/nvim/integration
test_nvim_integration tests/nvim/integration :
	nix build --no-link -L .#checks.x86_64-linux.nvim-integration

.PHONY : test_nvim_functional tests/nvim/functional
test_nvim_functional tests/nvim/functional :
	nix build --no-link -L .#checks.x86_64-linux.nvim-functional

# Cleaning
.PHONY : clean
clean :
	rm -rfv tests/.home
