#!/usr/bin/env lua5.2

local dir = require 'posix.dirent'.dir
local stats = require 'posix.sys.stat'
local isreg = require 'posix.sys.stat'.S_ISREG

-- Print the values of a nested list
local function print_ls(lst_of_lst)
    local header = string.format("%11s\t%8s", "Size", "Filename")
    print(header)
    for k, v in pairs(lst_of_lst) do
        for k1, v1 in pairs(v) do
            local output = string.format("%11d\t%8s", v1, k1)
            print(output)
        end
    end
end

local function is_reg_file(filename)
   local filestat = stats.lstat(filename)
   if isreg(filestat.st_mode) ~= 0 then
      return true
   else
      return false
   end
end

-- Return the file size of a filepath
local function file_size(filename)
    local fsize = stats.lstat(filename)
    return fsize.st_size
end

local function is_file(filename)
    local fsize = stats.lstat(filename)
    if fsize == nil then
        return false
    else
        return true
    end
end

-- Delete the value "." and ".." from the posix.dir API
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

-- Build a dictionary, the key is file name and the value is the file size.
local function group_size(filename)
    local dictionary = {}
    if filename == nil then
        print()
    else
        dictionary[filename] = file_size(filename)
    end

    return dictionary
end

-- If a file is a directory, concatenate this with the files
local function filepath(dirname, filenames)
    local filepaths = {}
    for i, file in pairs(filenames) do
        if file == nil then
	        print()
	    elseif string.sub(dirname, -1, -1) == "/" then
	        filepaths[i] = dirname .. file
        else
            filepaths[i] = dirname .. '/' .. file
        end
    end

    return filepaths
end

-- file size for a list of files
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

-- main function 
local function dir_sizes(filename)
   filename = filename or "."
   local files = clean_dir(filename)
   local true_paths = filepath(filename, files)
   local nested_list = files_sizes(filename, true_paths)
   print_ls(nested_list)
end

local function usage()
   print([[ls [options]
ls -v: print version
ls -h: print this menu]]) 
end

local function version()
    print "0.1.0"
end

if arg[1] == '-v' then
   version()
elseif arg[1] == '-h' then
   usage()
elseif arg[1] == nil then
   dir_sizes()
elseif is_file(arg[1]) then
   if is_reg_file(arg[1]) then
      for k,v in pairs(group_size(arg[1])) do
	 print(k, v)
      end
   else
      dir_sizes(arg[1])
   end
else
   usage()
end
