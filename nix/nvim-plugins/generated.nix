{ buildVimPlugin }:

{
  nvim-lua-guide = buildVimPlugin {
    pname = "nvim-lua-guide";
    version = "2022-03-14";
    src = builtins.fetchTree {
      type = "github";
      owner = "nanotee";
      repo = "nvim-lua-guide";
      rev = "32e1a4ed2e2fd384582e714e04d503a905c7f4e5";
      narHash = "sha256-YmDCzDq/MwfuOL5wWLw2Ak3bF+3/qcYFo+dOjy1Fkvs=";
    };
  };
  luv-vimdocs = buildVimPlugin {
    pname = "luv-vimdocs";
    version = "2022-03-27";
    src = builtins.fetchTree {
      type = "github";
      owner = "nanotee";
      repo = "luv-vimdocs";
      rev = "d1e34cb3dbec5ca5e7a5246f7a7186f8560ac716";
      narHash = "sha256-4iTrqXvqekkMXjlnyKMjTPhvvMaz086mDh1HhzM4zxw=";
    };
  };
  onedark-nvim = buildVimPlugin {
    pname = "onedark.nvim";
    version = "2022-03-29";
    src = builtins.fetchTree {
      type = "github";
      owner = "ful1e5";
      repo = "onedark.nvim";
      rev = "7b8ab0195efe9bbe07337419594e764167368a14";
      narHash = "sha256-H5n1ExX8RWOLE4hBLHrCER840/1EoRNEVI9L4W/eDtc=";
    };
  };
  surround-nvim = buildVimPlugin {
    pname = "surround.nvim";
    version = "2022-02-01";
    src = builtins.fetchTree {
      type = "github";
      owner = "ur4ltz";
      repo = "surround.nvim";
      rev = "549045828bbd9de0746b411a762fa8c382fb10ff";
      narHash = "sha256-XXR/48pbeGwKifYrhtEyMsOCUxejuIla60q0fSYFgTc=";
    };
  };
  tmux-nvim = buildVimPlugin {
    pname = "tmux.nvim";
    version = "2022-04-06";
    src = builtins.fetchTree {
      type = "github";
      owner = "aserowy";
      repo = "tmux.nvim";
      rev = "94a5b180b20b8374094f1170b26280898b4ca4d7";
      narHash = "sha256-2TV/SiIqcPzwq6f/Odn2JKaH0cGiNQ8ABqMSb4bXPw8=";
    };
  };
}
