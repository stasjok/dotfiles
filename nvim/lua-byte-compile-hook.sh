luaByteCompile() {
    echo "Executing luaByteCompile"

    if [[ -f $out ]]; then
        if [[ $out = *.lua ]]; then
            @nvimBin@ -l @luaByteCompileScript@ $out
        fi
    else
        (
            shopt -s nullglob globstar
            @nvimBin@ -l @luaByteCompileScript@ $out/**/*.lua
        )
    fi
}

preFixupHooks+=(luaByteCompile)
