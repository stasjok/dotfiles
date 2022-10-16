NVIM := nvim

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

define lua_get_vimruntime :=
io.stdout:write(vim.env.VIMRUNTIME);
vim.cmd.q()
endef

define lua_get_vim_pack_dir :=
io.stdout:write(vim.tbl_filter(function(s) return s:find("vim-pack-dir", 1, true) end, vim.opt.rtp:get())[1]);
vim.cmd.q()
endef

VIMRUNTIME := $(shell VIM= VIMRUNTIME= $(NVIM) --headless -u NONE -i NONE --cmd 'lua $(lua_get_vimruntime)')
VIMPACKDIR := $(shell $(NVIM) --headless -u NONE -i NONE --cmd 'lua $(lua_get_vim_pack_dir)')
nvim_home := $(abspath ./nvim)
nvim_init := $(nvim_home)/init.lua
nvim_rtp := $(nvim_home),$(VIMPACKDIR),$(VIMRUNTIME),$(nvim_home)/after
nvim_packpath := $(VIMPACKDIR),$(VIMRUNTIME)
nvim_rtp_args := --cmd "set rtp=$(nvim_rtp) packpath=$(nvim_packpath)"
nvim_args_minimal := --headless -n -i NONE -u NONE $(nvim_rtp_args)
nvim_args_full := --headless -n --clean -u $(nvim_init) $(nvim_rtp_args) --cmd 'lua vim.env.MYVIMRC = "$(nvim_init)"'

# Remove environment variables when running inside neovim terminal
unexport VIM VIMRUNTIME MYVIMRC LUA_PATH LUA_CPATH

.PHONY : $(nvim_unit)
$(nvim_unit) :
	$(NVIM) $(nvim_args_minimal) -c "lua require('plenary.busted').run('$@')"

.PHONY : $(nvim_integration)
$(nvim_integration) :
	$(NVIM) $(nvim_args_minimal) -c "lua require('plenary.busted').run('$@')"

.PHONY : $(nvim_functional)
$(nvim_functional) :
	$(NVIM) $(nvim_args_full) -c "lua require('plenary.busted').run('$@')"
