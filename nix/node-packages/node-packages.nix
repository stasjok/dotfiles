# This file has been generated by node2nix 1.9.0. Do not edit!

{nodeEnv, fetchurl, fetchgit, nix-gitignore, stdenv, lib, globalBuildInputs ? []}:

let
  sources = {
    "@flatten-js/interval-tree-1.0.18" = {
      name = "_at_flatten-js_slash_interval-tree";
      packageName = "@flatten-js/interval-tree";
      version = "1.0.18";
      src = fetchurl {
        url = "https://registry.npmjs.org/@flatten-js/interval-tree/-/interval-tree-1.0.18.tgz";
        sha512 = "o72sZErW0Y1C82Cg7nk82ojJ/22EtmKyp5I3eNqgcOKFp/VCzetATYYjJIqOBBaR7FQ/MFj/ZpsmP38mL4TkYA==";
      };
    };
    "@nodelib/fs.scandir-2.1.5" = {
      name = "_at_nodelib_slash_fs.scandir";
      packageName = "@nodelib/fs.scandir";
      version = "2.1.5";
      src = fetchurl {
        url = "https://registry.npmjs.org/@nodelib/fs.scandir/-/fs.scandir-2.1.5.tgz";
        sha512 = "vq24Bq3ym5HEQm2NKCr3yXDwjc7vTsEThRDnkp2DK9p1uqLR+DHurm/NOTo0KG7HYHU7eppKZj3MyqYuMBf62g==";
      };
    };
    "@nodelib/fs.stat-2.0.5" = {
      name = "_at_nodelib_slash_fs.stat";
      packageName = "@nodelib/fs.stat";
      version = "2.0.5";
      src = fetchurl {
        url = "https://registry.npmjs.org/@nodelib/fs.stat/-/fs.stat-2.0.5.tgz";
        sha512 = "RkhPPp2zrqDAQA/2jNhnztcPAlv64XdhIp7a7454A5ovI7Bukxgt7MX7udwAu3zg1DcpPU0rz3VV1SeaqvY4+A==";
      };
    };
    "@nodelib/fs.walk-1.2.8" = {
      name = "_at_nodelib_slash_fs.walk";
      packageName = "@nodelib/fs.walk";
      version = "1.2.8";
      src = fetchurl {
        url = "https://registry.npmjs.org/@nodelib/fs.walk/-/fs.walk-1.2.8.tgz";
        sha512 = "oGB+UxlgWcgQkgwo8GcEGwemoTFt3FIO9ababBmaGwXIoBKZ+GTy0pP185beGg7Llih/NSHSV2XAs1lnznocSg==";
      };
    };
    "braces-3.0.2" = {
      name = "braces";
      packageName = "braces";
      version = "3.0.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/braces/-/braces-3.0.2.tgz";
        sha512 = "b8um+L1RzM3WDSzvhm6gIz1yfTbBt6YTlcEKAvsmqCZZFw46z626lVj9j1yEPW33H5H+lBQpZMP1k8l+78Ha0A==";
      };
    };
    "core-js-3.21.1" = {
      name = "core-js";
      packageName = "core-js";
      version = "3.21.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/core-js/-/core-js-3.21.1.tgz";
        sha512 = "FRq5b/VMrWlrmCzwRrpDYNxyHP9BcAZC+xHJaqTgIE5091ZV1NTmyh0sGOg5XqpnHvR0svdy0sv1gWA1zmhxig==";
      };
    };
    "dir-glob-3.0.1" = {
      name = "dir-glob";
      packageName = "dir-glob";
      version = "3.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/dir-glob/-/dir-glob-3.0.1.tgz";
        sha512 = "WkrWp9GR4KXfKGYzOLmTuGVi1UWFfws377n9cc55/tb6DuqyF6pcQ5AbiHEshaDpY9v6oaSr2XCDidGmMwdzIA==";
      };
    };
    "fast-glob-3.2.11" = {
      name = "fast-glob";
      packageName = "fast-glob";
      version = "3.2.11";
      src = fetchurl {
        url = "https://registry.npmjs.org/fast-glob/-/fast-glob-3.2.11.tgz";
        sha512 = "xrO3+1bxSo3ZVHAnqzyuewYT6aMFHRAd4Kcs92MAonjwQZLsK9d0SF1IyQ3k5PoirxTW0Oe/RqFgMQ6TcNE5Ew==";
      };
    };
    "fastq-1.13.0" = {
      name = "fastq";
      packageName = "fastq";
      version = "1.13.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/fastq/-/fastq-1.13.0.tgz";
        sha512 = "YpkpUnK8od0o1hmeSc7UUs/eB/vIPWJYjKck2QKIzAf71Vm1AAQ3EbuZB3g2JIy+pg+ERD0vqI79KyZiB2e2Nw==";
      };
    };
    "fill-range-7.0.1" = {
      name = "fill-range";
      packageName = "fill-range";
      version = "7.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/fill-range/-/fill-range-7.0.1.tgz";
        sha512 = "qOo9F+dMUmC2Lcb4BbVvnKJxTPjCm+RRpe4gDuGrzkL7mEVl/djYSu2OdQ2Pa302N4oqkSg9ir6jaLWJ2USVpQ==";
      };
    };
    "glob-parent-5.1.2" = {
      name = "glob-parent";
      packageName = "glob-parent";
      version = "5.1.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/glob-parent/-/glob-parent-5.1.2.tgz";
        sha512 = "AOIgSQCepiJYwP3ARnGx+5VnTu2HBYdzbGP45eLw1vr3zB3vZLeyed1sC9hnbcOc9/SrMyM5RPQrkGz4aS9Zow==";
      };
    };
    "globby-13.1.1" = {
      name = "globby";
      packageName = "globby";
      version = "13.1.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/globby/-/globby-13.1.1.tgz";
        sha512 = "XMzoDZbGZ37tufiv7g0N4F/zp3zkwdFtVbV3EHsVl1KQr4RPLfNoT068/97RPshz2J5xYNEjLKKBKaGHifBd3Q==";
      };
    };
    "ignore-5.2.0" = {
      name = "ignore";
      packageName = "ignore";
      version = "5.2.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/ignore/-/ignore-5.2.0.tgz";
        sha512 = "CmxgYGiEPCLhfLnpPp1MoRmifwEIOgjcHXxOBjv7mY96c+eWScsOP9c112ZyLdWHi0FxHjI+4uVhKYp/gcdRmQ==";
      };
    };
    "ini-2.0.0" = {
      name = "ini";
      packageName = "ini";
      version = "2.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/ini/-/ini-2.0.0.tgz";
        sha512 = "7PnF4oN3CvZF23ADhA5wRaYEQpJ8qygSkbtTXWBeXWXmEVRXK+1ITciHWwHhsjv1TmW0MgacIv6hEi5pX5NQdA==";
      };
    };
    "is-extglob-2.1.1" = {
      name = "is-extglob";
      packageName = "is-extglob";
      version = "2.1.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/is-extglob/-/is-extglob-2.1.1.tgz";
        sha1 = "a88c02535791f02ed37c76a1b9ea9773c833f8c2";
      };
    };
    "is-glob-4.0.3" = {
      name = "is-glob";
      packageName = "is-glob";
      version = "4.0.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/is-glob/-/is-glob-4.0.3.tgz";
        sha512 = "xelSayHH36ZgE7ZWhli7pW34hNbNl8Ojv5KVmkJD4hBdD3th8Tfk9vYasLM+mXWOZhFkgZfxhLSnrwRr4elSSg==";
      };
    };
    "is-number-7.0.0" = {
      name = "is-number";
      packageName = "is-number";
      version = "7.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/is-number/-/is-number-7.0.0.tgz";
        sha512 = "41Cifkg6e8TylSpdtTpeLVMqvSBEVzTttHvERD741+pnZ8ANv0004MRL43QKPDlK9cGvNp6NZWZUBlbGXYxxng==";
      };
    };
    "jsonc-parser-3.0.0" = {
      name = "jsonc-parser";
      packageName = "jsonc-parser";
      version = "3.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/jsonc-parser/-/jsonc-parser-3.0.0.tgz";
        sha512 = "fQzRfAbIBnR0IQvftw9FJveWiHp72Fg20giDrHz6TdfB12UH/uue0D3hm57UB5KgAVuniLMCaS8P1IMj9NR7cA==";
      };
    };
    "lodash-4.17.21" = {
      name = "lodash";
      packageName = "lodash";
      version = "4.17.21";
      src = fetchurl {
        url = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
        sha512 = "v2kDEe57lecTulaDIuNTPy3Ry4gLGJ6Z1O3vE1krgXZNrsQ+LFTGHVxVjcXPs17LhbZVGedAJv8XZ1tvj5FvSg==";
      };
    };
    "merge2-1.4.1" = {
      name = "merge2";
      packageName = "merge2";
      version = "1.4.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/merge2/-/merge2-1.4.1.tgz";
        sha512 = "8q7VEgMJW4J8tcfVPy8g09NcQwZdbwFEqhe/WZkoIzjn/3TGDwtOCYtXGxA3O8tPzpczCCDgv+P2P5y00ZJOOg==";
      };
    };
    "micromatch-4.0.5" = {
      name = "micromatch";
      packageName = "micromatch";
      version = "4.0.5";
      src = fetchurl {
        url = "https://registry.npmjs.org/micromatch/-/micromatch-4.0.5.tgz";
        sha512 = "DMy+ERcEW2q8Z2Po+WNXuw3c5YaUSFjAO5GsJqfEl7UjvtIuFKO6ZrKvcItdy98dwFI2N1tg3zNIdKaQT+aNdA==";
      };
    };
    "path-type-4.0.0" = {
      name = "path-type";
      packageName = "path-type";
      version = "4.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/path-type/-/path-type-4.0.0.tgz";
        sha512 = "gDKb8aZMDeD/tZWs9P6+q0J9Mwkdl6xMV8TjnGP3qJVJ06bdMgkbBlLU8IdfOsIsFz2BW1rNVT3XuNEl8zPAvw==";
      };
    };
    "picomatch-2.3.1" = {
      name = "picomatch";
      packageName = "picomatch";
      version = "2.3.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/picomatch/-/picomatch-2.3.1.tgz";
        sha512 = "JU3teHTNjmE2VCGFzuY8EXzCDVwEqB2a8fsIvwaStHhAWJEeVd1o1QD80CU6+ZdEXXSLbSsuLwJjkCBWqRQUVA==";
      };
    };
    "queue-microtask-1.2.3" = {
      name = "queue-microtask";
      packageName = "queue-microtask";
      version = "1.2.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/queue-microtask/-/queue-microtask-1.2.3.tgz";
        sha512 = "NuaNSa6flKT5JaSYQzJok04JzTL1CA6aGhv5rfLW3PgqA+M2ChpZQnAC8h8i4ZFkBS8X5RqkDBHA7r4hej3K9A==";
      };
    };
    "regenerator-runtime-0.13.9" = {
      name = "regenerator-runtime";
      packageName = "regenerator-runtime";
      version = "0.13.9";
      src = fetchurl {
        url = "https://registry.npmjs.org/regenerator-runtime/-/regenerator-runtime-0.13.9.tgz";
        sha512 = "p3VT+cOEgxFsRRA9X4lkI1E+k2/CtnKtU4gcxyaCUreilL/vqI6CdZ3wxVUx3UOUg+gnUOQQcRI7BmSI656MYA==";
      };
    };
    "request-light-0.5.7" = {
      name = "request-light";
      packageName = "request-light";
      version = "0.5.7";
      src = fetchurl {
        url = "https://registry.npmjs.org/request-light/-/request-light-0.5.7.tgz";
        sha512 = "i/wKzvcx7Er8tZnvqSxWuNO5ZGggu2UgZAqj/RyZ0si7lBTXL7kZiI/dWxzxnQjaY7s5HEy1qK21Do4Ncr6cVw==";
      };
    };
    "reusify-1.0.4" = {
      name = "reusify";
      packageName = "reusify";
      version = "1.0.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/reusify/-/reusify-1.0.4.tgz";
        sha512 = "U9nH88a3fc/ekCF1l0/UP1IosiuIjyTh7hBvXVMHYgVcfGvt897Xguj2UOLDeI5BG2m7/uwyaLVT6fbtCwTyzw==";
      };
    };
    "run-parallel-1.2.0" = {
      name = "run-parallel";
      packageName = "run-parallel";
      version = "1.2.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/run-parallel/-/run-parallel-1.2.0.tgz";
        sha512 = "5l4VyZR86LZ/lDxZTR6jqL8AFE2S0IFLMP26AbjsLVADxHdhB/c0GUsH+y39UfCi3dzz8OlQuPmnaJOMoDHQBA==";
      };
    };
    "slash-4.0.0" = {
      name = "slash";
      packageName = "slash";
      version = "4.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/slash/-/slash-4.0.0.tgz";
        sha512 = "3dOsAHXXUkQTpOYcoAxLIorMTp4gIQr5IW3iVb7A7lFIp0VHhnynm9izx6TssdrIcVIESAlVjtnO2K8bg+Coew==";
      };
    };
    "to-regex-range-5.0.1" = {
      name = "to-regex-range";
      packageName = "to-regex-range";
      version = "5.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/to-regex-range/-/to-regex-range-5.0.1.tgz";
        sha512 = "65P7iz6X5yEr1cwcgvQxbbIw7Uk3gOy5dIdtZ4rDveLqhrdJP+Li/Hx6tyK0NEb+2GCyneCMJiGqrADCSNk8sQ==";
      };
    };
    "typescript-4.6.3" = {
      name = "typescript";
      packageName = "typescript";
      version = "4.6.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/typescript/-/typescript-4.6.3.tgz";
        sha512 = "yNIatDa5iaofVozS/uQJEl3JRWLKKGJKh6Yaiv0GLGSuhpFJe7P3SbHZ8/yjAHRQwKRoA6YZqlfjXWmVzoVSMw==";
      };
    };
    "uuid-8.3.2" = {
      name = "uuid";
      packageName = "uuid";
      version = "8.3.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/uuid/-/uuid-8.3.2.tgz";
        sha512 = "+NYs2QeMWy+GWFOEm9xnn6HCDp0l7QBD7ml8zLUmJ+93Q5NF0NocErnwkTkXVFNiX3/fpC6afS8Dhb/gz7R7eg==";
      };
    };
    "vscode-css-languageservice-5.4.1" = {
      name = "vscode-css-languageservice";
      packageName = "vscode-css-languageservice";
      version = "5.4.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-css-languageservice/-/vscode-css-languageservice-5.4.1.tgz";
        sha512 = "W7D3GKFXf97ReAaU4EZ2nxVO1kQhztbycJgc1b/Ipr0h8zYWr88BADmrXu02z+lsCS84D7Sr4hoUzDKeaFn2Kg==";
      };
    };
    "vscode-html-languageservice-4.2.4" = {
      name = "vscode-html-languageservice";
      packageName = "vscode-html-languageservice";
      version = "4.2.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-html-languageservice/-/vscode-html-languageservice-4.2.4.tgz";
        sha512 = "1HqvXKOq9WlZyW4HTD+0XzrjZoZ/YFrgQY2PZqktbRloHXVAUKm6+cAcvZi4YqKPVn05/CK7do+KBHfuSaEdbg==";
      };
    };
    "vscode-json-languageservice-4.2.1" = {
      name = "vscode-json-languageservice";
      packageName = "vscode-json-languageservice";
      version = "4.2.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-json-languageservice/-/vscode-json-languageservice-4.2.1.tgz";
        sha512 = "xGmv9QIWs2H8obGbWg+sIPI/3/pFgj/5OWBhNzs00BkYQ9UaB2F6JJaGB/2/YOZJ3BvLXQTC4Q7muqU25QgAhA==";
      };
    };
    "vscode-jsonrpc-6.0.0" = {
      name = "vscode-jsonrpc";
      packageName = "vscode-jsonrpc";
      version = "6.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-jsonrpc/-/vscode-jsonrpc-6.0.0.tgz";
        sha512 = "wnJA4BnEjOSyFMvjZdpiOwhSq9uDoK8e/kpRJDTaMYzwlkrhG1fwDIZI94CLsLzlCK5cIbMMtFlJlfR57Lavmg==";
      };
    };
    "vscode-jsonrpc-8.0.0-next.7" = {
      name = "vscode-jsonrpc";
      packageName = "vscode-jsonrpc";
      version = "8.0.0-next.7";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-jsonrpc/-/vscode-jsonrpc-8.0.0-next.7.tgz";
        sha512 = "JX/F31LEsims0dAlOTKFE4E+AJMiJvdRSRViifFJSqSN7EzeYyWlfuDchF7g91oRNPZOIWfibTkDf3/UMsQGzQ==";
      };
    };
    "vscode-languageserver-7.0.0" = {
      name = "vscode-languageserver";
      packageName = "vscode-languageserver";
      version = "7.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver/-/vscode-languageserver-7.0.0.tgz";
        sha512 = "60HTx5ID+fLRcgdHfmz0LDZAXYEV68fzwG0JWwEPBode9NuMYTIxuYXPg4ngO8i8+Ou0lM7y6GzaYWbiDL0drw==";
      };
    };
    "vscode-languageserver-8.0.0-next.10" = {
      name = "vscode-languageserver";
      packageName = "vscode-languageserver";
      version = "8.0.0-next.10";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver/-/vscode-languageserver-8.0.0-next.10.tgz";
        sha512 = "sdjldl9ipuBSWVw5ENVMRcOVQwF0o+J6+lNA7FrB8MiLmzflnfjRoJMqA5tCEY8S/J/+P56ZR/dqiQnRYg5m8w==";
      };
    };
    "vscode-languageserver-protocol-3.16.0" = {
      name = "vscode-languageserver-protocol";
      packageName = "vscode-languageserver-protocol";
      version = "3.16.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver-protocol/-/vscode-languageserver-protocol-3.16.0.tgz";
        sha512 = "sdeUoAawceQdgIfTI+sdcwkiK2KU+2cbEYA0agzM2uqaUy2UpnnGHtWTHVEtS0ES4zHU0eMFRGN+oQgDxlD66A==";
      };
    };
    "vscode-languageserver-protocol-3.17.0-next.16" = {
      name = "vscode-languageserver-protocol";
      packageName = "vscode-languageserver-protocol";
      version = "3.17.0-next.16";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver-protocol/-/vscode-languageserver-protocol-3.17.0-next.16.tgz";
        sha512 = "tx4DnXw9u3N7vw+bx6n2NKp6FoxoNwiP/biH83AS30I2AnTGyLd7afSeH6Oewn2E8jvB7K15bs12sMppkKOVeQ==";
      };
    };
    "vscode-languageserver-textdocument-1.0.4" = {
      name = "vscode-languageserver-textdocument";
      packageName = "vscode-languageserver-textdocument";
      version = "1.0.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver-textdocument/-/vscode-languageserver-textdocument-1.0.4.tgz";
        sha512 = "/xhqXP/2A2RSs+J8JNXpiiNVvvNM0oTosNVmQnunlKvq9o4mupHOBAnnzH0lwIPKazXKvAKsVp1kr+H/K4lgoQ==";
      };
    };
    "vscode-languageserver-types-3.16.0" = {
      name = "vscode-languageserver-types";
      packageName = "vscode-languageserver-types";
      version = "3.16.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver-types/-/vscode-languageserver-types-3.16.0.tgz";
        sha512 = "k8luDIWJWyenLc5ToFQQMaSrqCHiLwyKPHKPQZ5zz21vM+vIVUSvsRpcbiECH4WR88K2XZqc4ScRcZ7nk/jbeA==";
      };
    };
    "vscode-languageserver-types-3.17.0-next.9" = {
      name = "vscode-languageserver-types";
      packageName = "vscode-languageserver-types";
      version = "3.17.0-next.9";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver-types/-/vscode-languageserver-types-3.17.0-next.9.tgz";
        sha512 = "9/PeDNPYduaoXRUzYpqmu4ZV9L01HGo0wH9FUt+sSHR7IXwA7xoXBfNUlv8gB9H0D2WwEmMomSy1NmhjKQyn3A==";
      };
    };
    "vscode-nls-5.0.0" = {
      name = "vscode-nls";
      packageName = "vscode-nls";
      version = "5.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-nls/-/vscode-nls-5.0.0.tgz";
        sha512 = "u0Lw+IYlgbEJFF6/qAqG2d1jQmJl0eyAGJHoAJqr2HT4M2BNuQYSEiSE75f52pXHSJm8AlTjnLLbBFPrdz2hpA==";
      };
    };
    "vscode-uri-3.0.3" = {
      name = "vscode-uri";
      packageName = "vscode-uri";
      version = "3.0.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-uri/-/vscode-uri-3.0.3.tgz";
        sha512 = "EcswR2S8bpR7fD0YPeS7r2xXExrScVMxg4MedACaWHEtx9ftCF/qHG1xGkolzTPcEmjTavCQgbVzHUIdTMzFGA==";
      };
    };
    "yaml-1.10.2" = {
      name = "yaml";
      packageName = "yaml";
      version = "1.10.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/yaml/-/yaml-1.10.2.tgz";
        sha512 = "r3vXyErRCYJ7wg28yvBY5VSoAF8ZvlcW9/BwUzEtUsjvX/DKs24dIkuwjtuprwJJHsbyUbLApepYTR1BN4uHrg==";
      };
    };
    "yarn-1.22.18" = {
      name = "yarn";
      packageName = "yarn";
      version = "1.22.18";
      src = fetchurl {
        url = "https://registry.npmjs.org/yarn/-/yarn-1.22.18.tgz";
        sha512 = "oFffv6Jp2+BTUBItzx1Z0dpikTX+raRdqupfqzeMKnoh7WD6RuPAxcqDkMUy9vafJkrB0YaV708znpuMhEBKGQ==";
      };
    };
  };
in
{
  vscode-langservers-extracted = nodeEnv.buildNodePackage {
    name = "vscode-langservers-extracted";
    packageName = "vscode-langservers-extracted";
    version = "4.1.0";
    src = fetchurl {
      url = "https://registry.npmjs.org/vscode-langservers-extracted/-/vscode-langservers-extracted-4.1.0.tgz";
      sha512 = "HZfrlqpVu8N0UkSyjldPsGFpVFByYaDRDMmBvmKwKai2rAsd2vtde2CFnX9rOpmg3pN2vET8j3qtqZvZLzmkjQ==";
    };
    dependencies = [
      sources."core-js-3.21.1"
      sources."jsonc-parser-3.0.0"
      sources."regenerator-runtime-0.13.9"
      sources."request-light-0.5.7"
      sources."typescript-4.6.3"
      sources."vscode-css-languageservice-5.4.1"
      sources."vscode-html-languageservice-4.2.4"
      sources."vscode-json-languageservice-4.2.1"
      sources."vscode-jsonrpc-8.0.0-next.7"
      sources."vscode-languageserver-8.0.0-next.10"
      (sources."vscode-languageserver-protocol-3.17.0-next.16" // {
        dependencies = [
          sources."vscode-languageserver-types-3.17.0-next.9"
        ];
      })
      sources."vscode-languageserver-textdocument-1.0.4"
      sources."vscode-languageserver-types-3.16.0"
      sources."vscode-nls-5.0.0"
      sources."vscode-uri-3.0.3"
      sources."yarn-1.22.18"
    ];
    buildInputs = globalBuildInputs;
    meta = {
      description = "HTML/CSS/JSON language servers extracted from [vscode](https://github.com/Microsoft/vscode).";
      homepage = "https://github.com/hrsh7th/vscode-langservers-extracted#readme";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
  "@ansible/ansible-language-server" = nodeEnv.buildNodePackage {
    name = "_at_ansible_slash_ansible-language-server";
    packageName = "@ansible/ansible-language-server";
    version = "0.5.4";
    src = fetchurl {
      url = "https://registry.npmjs.org/@ansible/ansible-language-server/-/ansible-language-server-0.5.4.tgz";
      sha512 = "PRjqGWBgYFkR+FOmquqObsYSFZt/BDYUfmc1dg2OCLU0f3dT7kf0d7oL19n/Pjhl5qlHZ4gQC1o9fxuJ4iD4Ww==";
    };
    dependencies = [
      sources."@flatten-js/interval-tree-1.0.18"
      sources."@nodelib/fs.scandir-2.1.5"
      sources."@nodelib/fs.stat-2.0.5"
      sources."@nodelib/fs.walk-1.2.8"
      sources."braces-3.0.2"
      sources."dir-glob-3.0.1"
      sources."fast-glob-3.2.11"
      sources."fastq-1.13.0"
      sources."fill-range-7.0.1"
      sources."glob-parent-5.1.2"
      sources."globby-13.1.1"
      sources."ignore-5.2.0"
      sources."ini-2.0.0"
      sources."is-extglob-2.1.1"
      sources."is-glob-4.0.3"
      sources."is-number-7.0.0"
      sources."lodash-4.17.21"
      sources."merge2-1.4.1"
      sources."micromatch-4.0.5"
      sources."path-type-4.0.0"
      sources."picomatch-2.3.1"
      sources."queue-microtask-1.2.3"
      sources."reusify-1.0.4"
      sources."run-parallel-1.2.0"
      sources."slash-4.0.0"
      sources."to-regex-range-5.0.1"
      sources."uuid-8.3.2"
      sources."vscode-jsonrpc-6.0.0"
      sources."vscode-languageserver-7.0.0"
      sources."vscode-languageserver-protocol-3.16.0"
      sources."vscode-languageserver-textdocument-1.0.4"
      sources."vscode-languageserver-types-3.16.0"
      sources."vscode-uri-3.0.3"
      sources."yaml-1.10.2"
    ];
    buildInputs = globalBuildInputs;
    meta = {
      description = "Ansible language server";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
}
