#!/usr/bin/env python3

from datetime import date
import json
from pathlib import Path
from subprocess import PIPE, run


DIR = Path(__file__).parent
PLUGINS = Path.joinpath(DIR, "plugins.json")
GENERATED = Path.joinpath(DIR, "generated.nix")
HEADER = """{ buildVimPlugin }:

{
"""
TAIL = """}"""
TEMPLATE = """  {name} = buildVimPlugin {{
    pname = "{pname}";
    version = "{version}";
    src = builtins.fetchTree {{
      {src}
    }};
  }};
"""
GITHUB_TEMPLATE = """type = "github";
      owner = "{owner}";
      repo = "{repo}";
      rev = "{rev}";
      narHash = "{hash}";"""
GIT_TEMPLATE = """type = "git";
      url = {url};
      ref = "{ref}";
      rev = "{rev}";
      narHash = "{hash}";"""


def get_nix_args(args: dict[str, str]) -> list[str]:
    new_args = []
    for k, v in args.items():
        new_args.append(f'{k}="{v}";')
    new_args_str = " ".join(new_args)
    return [
        "nix",
        "eval",
        "--impure",
        "--json",
        "--expr",
        f'removeAttrs (builtins.fetchTree {{ {new_args_str} }}) [ "outPath" ]',
    ]


def escape_name(name: str) -> str:
    return name.replace(".", "-")


def main() -> None:
    with Path.joinpath(DIR, "plugins.json").open() as f:
        plugins = json.load(f)
    result = HEADER
    # Github plugins
    github_plugins: list[str] = plugins.get("github", [])
    for plugin in github_plugins:
        parts = plugin.split("/")
        src_args = {
            "type": "github",
            "owner": parts[0],
            "repo": parts[1],
        }
        try:
            src_args["rev"] = parts[2]
        except IndexError:
            pass
        nix_args = get_nix_args(src_args)
        nix_output = run(nix_args, stdout=PIPE, check=True)
        plugin_src = json.loads(nix_output.stdout)
        src_args["hash"] = plugin_src["narHash"]
        src_args["rev"] = plugin_src["rev"]
        repo = src_args["repo"]
        plugin_args = {
            "name": escape_name(repo),
            "pname": repo,
            "version": date.fromtimestamp(plugin_src["lastModified"]),
            "src": GITHUB_TEMPLATE.format(**src_args),
        }
        result += TEMPLATE.format(**plugin_args)
    # Git plugins
    git_plugins: list[dict[str, str]] = plugins.get("git", [])
    for plugin in git_plugins:
        src_args = plugin.copy()
        src_args["type"] = "git"
        nix_args = get_nix_args(src_args)
        nix_output = run(nix_args, stdout=PIPE, check=True)
        plugin_src = json.loads(nix_output.stdout)
        src_args.update(
            {
                "ref": plugin.get("ref", "master"),
                "rev": plugin_src["rev"],
                "hash": plugin_src["narHash"],
            }
        )
        pname = plugin["url"].split("/")[-1].removesuffix(".git")
        plugin_args = {
            "name": escape_name(pname),
            "pname": pname,
            "version": date.fromtimestamp(plugin_src["lastModified"]),
            "src": GIT_TEMPLATE.format(**src_args),
        }
        result += TEMPLATE.format(**plugin_args)
    result += TAIL
    Path(GENERATED).write_text(result)


if __name__ == "__main__":
    main()
