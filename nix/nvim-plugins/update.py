#!/usr/bin/env python3

from datetime import date
import json
from pathlib import Path
import re
from subprocess import PIPE, run
from urllib.parse import parse_qs, urlsplit, urlunsplit


DIR = Path(__file__).parent
PLUGINS = Path.joinpath(DIR, "plugins")
GENERATED = Path.joinpath(DIR, "generated.nix")
HEADER = """{ buildVimPlugin }:

{
"""
TAIL = "}\n"
TEMPLATE = """  {name} = buildVimPlugin {{
    pname = "{pname}";
    version = "{version}";
    src = builtins.fetchTree {{
{src}
    }};
  }};
"""


def process_line(line: str) -> str:
    parsed = urlsplit(line)
    if parsed.netloc:
        # Git
        args = {
            "type": "git",
            "url": urlunsplit(parsed._replace(query="")),
        }
        name = parsed.path.split("/")[-1].removesuffix(".git")
    else:
        # GitHub
        parts = parsed.path.split("/")
        args = {
            "type": "github",
            "owner": parts[0],
            "repo": parts[1],
        }
        try:
            args.update(rev_or_ref(parts[2]))
        except IndexError:
            pass
        name = parts[1]
    args.update(parse_query(parsed.query))

    nix_args = get_nix_args(args)
    nix_output = run(nix_args, stdout=PIPE, check=True)
    plugin_src = json.loads(nix_output.stdout)
    args["rev"] = plugin_src["rev"]
    args["narHash"] = plugin_src["narHash"]
    plugin_args = {
        "name": escape_name(name),
        "pname": name,
        "version": date.fromtimestamp(plugin_src["lastModified"]),
        "src": to_nix_attrs(args, 6),
    }
    return TEMPLATE.format(**plugin_args)


def rev_or_ref(rev: str) -> dict[str, str]:
    if re.fullmatch("[a-f0-9]{40}", rev):
        t = "rev"
    else:
        t = "ref"
    return {t: rev}


def parse_query(query: str) -> dict[str, str]:
    return dict(map(lambda kv: (kv[0], kv[1][-1]), parse_qs(query).items()))


def to_nix_attrs(attrs: dict[str, str], indent=0, sep="\n") -> str:
    lines = []
    for k, v in attrs.items():
        lines.append(f'{"":>{indent}}{k} = "{v}";')
    return sep.join(lines)


def get_nix_args(args: dict[str, str]) -> list[str]:
    return [
        "nix",
        "eval",
        "--impure",
        "--json",
        "--expr",
        f'removeAttrs (builtins.fetchTree {{ {to_nix_attrs(args, sep=" ")} }}) [ "outPath" ]',
    ]


def escape_name(name: str) -> str:
    return name.replace(".", "-")


def main() -> None:
    result = HEADER
    with PLUGINS.open() as f:
        for line in f:
            l = line.strip()
            if l and not l.startswith("#"):
                result += process_line(l)
    result += TAIL
    Path(GENERATED).write_text(result)


if __name__ == "__main__":
    main()
