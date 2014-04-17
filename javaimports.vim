" javaimports.vim -- Manage java imports and packages
" Author: Johan Venant <jvenant@invicem.pro>
" Last Modified: 17-Apr-2014 15:36
" Requires: Vim-6.0 or higher
" Version: 1.0
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 
" Download From:
"     https://github.com/jvenant/javaimports
" Summary Of Features:
"   Insert import
"   Sort imports
"   Insert package declaration
" Usage:
"   Copy this file in your vim plugin folder  
"   No classpath or configuration needed. This plugin use the regular vim search.  
"   So you only need a good search index (through ctags or cscope for example)
" Commands:
"   <Leader>is Sort imports
"   <Leader>ia Search class from <cword>, add it to the imports and sort imports
"   <Leader>ip add or replace package declaration
"   You can define the package sort order using g:sortedPackage
"   You can define the package deth blank line separator using g:packageSepDepth
" Notes:
"   This plugin is an improvement of the anonymous function found here :
"   http://vim.wikia.com/wiki/Add_Java_import_statements_automatically
if exists("g:loaded_sortimport") || &cp
  finish
endif
let g:loaded_sortimport= 1

if !hasmapto('<Plug>JavaSortImport')
  map <unique> <Leader>is <Plug>JavaSortImport
endif
if !hasmapto('<Plug>JavaInsertImport')
  map <unique> <Leader>ia <Plug>JavaInsertImport
endif
if !hasmapto('<Plug>JavaInsertPackage')
  map <unique> <Leader>ip <Plug>JavaInsertPackage
endif

map <silent> <script> <Plug>JavaSortImport :set lz<CR>:call <SID>JavaSortImport()<CR>:set nolz<CR>
map <silent> <script> <Plug>JavaInsertImport :call <SID>JavaInsertSortImport()<CR>
map <silent> <script> <Plug>JavaInsertPackage :set lz<CR>:call <SID>JavaInsertPackage()<CR>:set nolz<CR>

let g:sortedPackage = ["java","javax", "org", "com"]
let g:packageSepDepth = 2

let s:importPattern = '^\s*import\s\+.*;'
fun! s:JavaSortImport()
    1
    if search(s:importPattern) > 0
        let firstLine = line(".")
        normal! G
        exe "" . firstLine . "," . search(s:importPattern, 'b') . "sort u"
        if getline(".") =~ "^\s*$"
            delete
        endif
        1
        for name in g:sortedPackage
            let pattern = '\s*import\s\+' . name . '\..*;'
            if search(pattern) > 0
                let @a = ""
                exe 'g/' . pattern . '/d A'
                exe firstLine
                normal! "aPddG
                exe search(pattern, 'b')
                normal! j
                let firstLine = line(".")
            endif
        endfor
        1
        while search(s:importPattern, 'W') > 0
            let curLine = getline(".")
            let curMatch = substitute(curLine, '\(^\s*import\s\+\(\.\?[^\.]\+\)\{0,' . g:packageSepDepth . '\}\).*', '\1', "")
            if (curMatch == curLine)
                let curMatch = substitute(curMatch, '\(.*\)\..*', '\1', "")
            endif
            while match(getline("."), curMatch) >= 0
                normal! j
            endwhile
            normal! O
        endwhile
        if getline(".") =~ "^$"
          delete
        endif
    endif
endfun

fun! s:JavaInsertSortImport()
    call s:JavaInsertImport()
    split
    call s:JavaSortImport()
    quit
endfun

fun! s:JavaInsertImport()
  exe "normal mz"
  let cur_class = expand("<cword>")
  try
    if search('^\s*import\s.*\.' . cur_class . '\s*;') > 0
      throw getline('.') . ": import already exist!"
    endif
    wincmd }
    wincmd P
    1
    if search('^\s*public.*\s\%(class\|interface\)\s\+' . cur_class) > 0
      1
      if search('^\s*package\s') > 0
        yank y
      else
        throw "Package definition not found!"
      endif
    else
      if search('^\s*import\s.*\.' . cur_class . '\s*;') > 0
        yank y
      else
        throw cur_class . ": class not found!"
      endif
    endif
    wincmd p
    normal! G
    " insert after last import or in first line
    if search('^\s*import\s', 'b') > 0
      put y
    else
      if search('^\s*package\s', 'b') > 0
        exe "normal o"
        put y
      else
        1
        put! y
      endif
    endif
    if match(getline("."), '^\s*package\s\+.*') >= 0
        substitute/^\s*package/import/g
        substitute/\s\+/ /g
        exe "normal! 2ER." . cur_class . ";\<Esc>lD"
    endif
  catch /.*/
    echoerr v:exception
  finally
    " wipe preview window (from buffer list)
    silent! wincmd P
    if &previewwindow
      bwipeout
    endif
    exe "normal! `z"
  endtry
endfun

fun! s:JavaInsertPackage()
  let dir = getcwd() . "/" . expand("%")
  let dir = substitute(dir, "^.*\/main\/java\/", "", "")
  let dir = substitute(dir, "\/[^\/]*$", "", "")
  let dir = substitute(dir, "\/", ".", "g")
  1
  if search('^\s*package\s.*', '') == 0
      normal! O
  endif
  exe "normal ^Cpackage " . dir . ";"
endfun
