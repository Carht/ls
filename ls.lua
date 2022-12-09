#!/usr/bin/env lua5.2

local dir = require 'posix.dirent'.dir
local stats = require 'posix.sys.stat'

local function nested_lost(lst_of_lst)
    for k, v in pairs(lst_of_lst) do
        for k1, v1 in pairs(v) do
            print(k1 .. '\t' .. v1)
        end
    end
end

local function file_size(filename)
    local fsize = stats.lstat(filename)
    return fsize.st_size
end

local function clean_dir(filename)
    local files = dir(filename)
    local clean_arr = {}
    for k, v in pairs(files) do
        if v == "." or v == ".." then
            clean_arr[k] = nil
        else
            clean_arr[k] = v
        end
    end
    return clean_arr
end

local function group_size(filename)
    local dictionary = {}
    if filename == nil then
        print()
    else
        dictionary[filename] = file_size(filename)
    end

    return dictionary
end

local function filepath(dirname, filenames)
    local filepaths = {}
    for i, file in pairs(filenames) do
        if file == nil then
            print()
        else
            filepaths[i] = dirname .. '/' .. file
        end
    end

    return filepaths
end

local function files_sizes(filename, filenames)
    local groups = {}
    for k, file in pairs(filenames) do
        if file == nil then
            print()
        else
            groups[k] = group_size(file)
        end
    end
    return groups
end

local function dir_sizes(filename)
    local files = clean_dir(filename)
    local true_paths = filepath(filename, files)
    local nested_list = files_sizes(filename, true_paths)
    nested_lost(nested_list)
end

dir_sizes("/home")
dir_sizes("/etc")