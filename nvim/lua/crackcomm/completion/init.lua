local luasnip = require("luasnip")
local lspkind = require("lspkind")
local cmp = require("cmp")

local _cmp_format = lspkind.cmp_format({
  with_text = true,
  menu = {
    buffer = "[buf]",
    nvim_lsp = "[LSP]",
    nvim_lua = "[api]",
    path = "[path]",
    -- luasnip = "[snip]",
    -- gh_issues = "[issues]",
    -- tn = "[TabNine]",
    -- eruby = "[erb]",
    cody = "[cody]",
    copilot = "[copilot]",
  },
})

local cmp_format = function(entry, vim_item)
  vim_item = _cmp_format(entry, vim_item)

  if entry.source.name == "nvim_lsp" then
    local lsp_name = entry.source.source and entry.source.source.client and entry.source.source.client.name
    vim_item.menu = "[" .. lsp_name .. "]"
  end

  return vim_item
end

cmp.setup({
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = {
    ["<s-tab>"] = cmp.mapping.complete(),
    ["<c-n>"] = cmp.mapping(function(
      _ --[[fallback]]
    )
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
      else
        cmp.complete()
      end
    end),
    ["<c-p>"] = cmp.mapping(function(
      _ --[[fallback]]
    )
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
      else
        cmp.complete()
      end
    end),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<c-y>"] = cmp.mapping(
      cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      }),
      { "i", "c" }
    ),
    ["<M-y>"] = cmp.mapping(
      cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      }),
      { "i", "c" }
    ),

    -- Cody completion
    ["<c-a>"] = cmp.mapping.complete({
      config = {
        sources = {
          { name = "cody" },
          { name = "copilot" },
        },
      },
    }),

    -- ["<tab>"] = cmp.config.disable,
    ["<tab>"] = cmp.mapping({
      i = cmp.config.disable,
    }),

    -- Testing
    ["<c-q>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    }),
  },
  sources = cmp.config.sources({
    { name = "cody" },
    { name = "copilot" },
    { name = "nvim_lsp" },
    -- { name = "nvim_lua" },
    -- { name = "luasnip" },
    -- { name = "eruby" },
  }, {
    { name = "path" },
    { name = "buffer", keyword_length = 5 },
  }, {
    -- { name = "gh_issues" },
  }),

  sorting = {
    priority_weight = 2,
    comparators = {
      function(entry1, entry2)
        local name1 = entry1.source.source and entry1.source.source.client and entry1.source.source.client.name
        local name2 = entry2.source.source and entry2.source.source.client and entry2.source.source.client.name

        if name1 == "llmlsp" and name2 ~= "llmlsp" then
          return true
        elseif name1 ~= "llmlsp" and name2 == "llmlsp" then
          return false
        end
        return nil
      end,

      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,

      -- copied from cmp-under, but I don't think I need the plugin for this.
      -- I might add some more of my own.
      function(entry1, entry2)
        local _, entry1_under = entry1.completion_item.label:find("^_+")
        local _, entry2_under = entry2.completion_item.label:find("^_+")
        entry1_under = entry1_under or 0
        entry2_under = entry2_under or 0
        if entry1_under > entry2_under then
          return false
        elseif entry1_under < entry2_under then
          return true
        end
      end,

      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  formatting = {
    format = cmp_format,
  },

  experimental = {
    -- I like the new menu better! Nice work hrsh7th
    native_menu = false,

    -- for AI assistants
    ghost_text = true,
  },

  -- pretty much unique to gopls
  -- preselect = cmp.PreselectMode.None,
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    {
      name = "cmdline",
      option = {
        ignore_cmds = { "Man", "!", "lua" },
      },
    },
  }),
})
