# Vim java imports manager
---
### Licence:
This program is free software; you can redistribute it and/or  
modify it under the terms of the GNU General Public License.  
See http://www.gnu.org/copyleft/gpl.txt 
### Summary Of Features:
  * Insert import
  * Sort imports
  * Insert package declaration

### Usage:
  Copy this file in your vim plugin folder  
  No classpath or configuration needed. This plugin use the regular vim search.  
  So you only need a good seach index (through ctags or cscope for example)
 
### Commands
  * &lt;Leader&gt;is Sort imports
  * &lt;Leader&gt;ia Search class from <cword>, add it to the imports and sort imports
  * &lt;Leader&gt;ip add or replace package declaration
  * You can define the package sort order using g:sortedPackage
  * You can define the package deth blank line separator using g:packageSepDepth

### Notes:
  This plugin is an improvment of the anonymous function found here :
  http://vim.wikia.com/wiki/Add_Java_import_statements_automatically
