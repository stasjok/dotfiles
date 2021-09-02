local jsonls = {}

jsonls.settings = {
  json = {
    schemas = {
      {
        fileMatch = {
          "/nvim/snippets/*.json",
          "!package.json",
        },
        schema = {
          allowComments = false,
          allowTrailingCommas = false,
          type = "object",
          description = "User snippet configuration",
          defaultSnippets = {
            {
              label = "Empty snippet",
              body = {
                ["${1:snippetName}"] = {
                  prefix = "${2:prefix}",
                  body = "${3:snippet}",
                  description = "${4:description}",
                },
              },
            },
          },
          additionalProperties = {
            type = "object",
            required = { "body" },
            additionalProperties = false,
            defaultSnippets = {
              {
                label = "Snippet",
                body = {
                  prefix = "${1:prefix}",
                  body = "${2:snippet}",
                  description = "${3:description}",
                },
              },
            },
            properties = {
              prefix = {
                description = "The prefix to use when selecting the snippet in intellisense",
                type = { "string", "array" },
              },
              body = {
                markdownDescription = "The snippet content. Use `$1`, `${1:defaultText}` to define cursor positions, use `$0` for the final cursor position. Insert variable values with `${varName}` and `${varName:defaultText}`, e.g. `This is file: $TM_FILENAME`.",
                type = { "string", "array" },
                items = { type = "string" },
              },
              description = {
                description = "The snippet description.",
                type = { "string", "array" },
              },
            },
          },
        },
      },
    },
  },
}

return jsonls
