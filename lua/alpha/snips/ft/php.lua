local ls = require("luasnip")

local snippet_from_nodes = ls.sn
local c = ls.choice_node
local t = ls.text_node
local d = ls.dynamic_node
local f = ls.function_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt


function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

local newline = function(text)
  return t { "", text }
end

local visibility = function(_, _, _, inital)
    local possibles = {'private', 'public', 'protected'}

    local options = {}

    for _, value in pairs(possibles) do
        if value == inital then
            table.insert(options, 1, t(value))
        else
            table.insert(options, t(value))
        end
    end

    return snippet_from_nodes(nil, {
        c(1, options)
    })
end

local promoted_property
promoted_property = function()
    return snippet_from_nodes(nil, {
        c(1, {
            t(""),
            snippet_from_nodes(nil, {
                newline "\t",
                d(1, visibility, {}, "private"),
                i(2, '$var'),
                t ",",
                d(3, promoted_property, {})
            }),
        }),
    })
end

local namespace = function ()
    local dir = vim.fn.expand('%:h')
    local autoloads = vim.call('composer#query', 'autoload.psr-4')
    if autoloads == nil then
        return (dir:gsub("^%l", string.upper))
    end

    local globalNamespace
    for key, value in pairs(autoloads) do
        if string.starts(dir, value:sub(1, -2)) then
            globalNamespace = key:sub(1, -2);
            dir = dir:sub(#key + 1)
            break
        end
    end
    dir = dir:gsub("/", "\\")

    return string.format("%s\\%s",globalNamespace, dir )
end

local class_name = function ()
    local filename = vim.fn.expand('%:t:r')
    return filename
end
local M = {
    v = fmt(
[[
/**
 * @var {}
 */
{} ${};
]], {
            i(1, "type"),
            d(2, visibility, { 1 }, "private"),
            i(3, "var")
        }),
    class = fmt(
[[
<?php

declare(strict_types=1);

namespace [];

class []
{
    []
}
]],
    {
        f(namespace),
        f(class_name),
        i(0),
    }, { delimiters = "[]"}),
}

return M
