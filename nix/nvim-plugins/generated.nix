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
}