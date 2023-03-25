# MIT License
#
# Copyright (c) 2023 Björn Rennfanz
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

if(CMAKE_BINARY_DIR)
  message(FATAL_ERROR "CPackConan.cmake may only be used by CPack External")
endif()

if(NOT CPACK_CONAN_COMPONENT_INSTALL)
  message(WARNING "CPack: [Conan] CPACK_CONAN_COMPONENT_INSTALL is not enabled")
  return()
endif()

function(_cpack_conan_debug)
  if(CPACK_CONAN_PACKAGE_DEBUG)
    message("CPack Debug: [Conan] " ${ARGN})
  endif()
endfunction()

function(_cpack_conan_debug_var NAME)
  if(CPACK_CONAN_PACKAGE_DEBUG)
    message("CPack Debug: [Conan] ${NAME}=\"${${NAME}}\"")
  endif()
endfunction()

function(_cpack_conan_setup_group_components _ignoreGroups)
  if(NOT ${_ignoreGroups})
    foreach(_component IN LISTS CPACK_COMPONENTS_ALL)
      string(MAKE_C_IDENTIFIER "${_component}" _component_up)
      string(TOUPPER "${_component_up}" _component_up)
      if (NOT "${CPACK_COMPONENT_${_component_up}_GROUP}" STREQUAL "")
        set(_group "${CPACK_COMPONENT_${_component_up}_GROUP}")
        string(MAKE_C_IDENTIFIER "${_group}" _group_up)
        string(TOUPPER "${_group_up}" _group_up)
        list(APPEND _groups "${_group}")
        list(APPEND CPACK_CONAN_${_group_up}_GROUP_COMPONENTS "${_component}")
        list(REMOVE_DUPLICATES CPACK_CONAN_${_group_up}_GROUP_COMPONENTS)
        set(CPACK_CONAN_${_group_up}_GROUP_COMPONENTS "${CPACK_CONAN_${_group_up}_GROUP_COMPONENTS}" PARENT_SCOPE)
      endif()
    endforeach()
    list(REMOVE_DUPLICATES _groups)
    set(CPACK_CONAN_GROUPS "${_groups}" PARENT_SCOPE)
  endif()
  foreach(_component IN LISTS CPACK_COMPONENTS_ALL)
    string(MAKE_C_IDENTIFIER "${_component}" _component_up)
    string(TOUPPER "${_component_up}" _component_up)
    if ("${CPACK_COMPONENT_${_component_up}_GROUP}" STREQUAL "")
      list(APPEND CPACK_CONAN_COMPONENTS "${_component}")
    endif()
  endforeach()
  set(CPACK_CONAN_COMPONENTS "${CPACK_CONAN_COMPONENTS}" PARENT_SCOPE)
endfunction()

# Are we in the component packaging case
if(NOT CPACK_MONOLITHIC_INSTALL)
  if(CPACK_COMPONENTS_GROUPING STREQUAL "ALL_COMPONENTS_IN_ONE")
    # CASE 1 : COMPONENT ALL-IN-ONE package
    # Meaning that all per-component pre-installed files
    # goes into the single package.
    _cpack_conan_setup_group_components(TRUE)
    set(CPACK_CONAN_ALL_IN_ONE TRUE)
  else()
    # CASE 2 : COMPONENT CLASSICAL package(s) (i.e. not all-in-one)
    # There will be 1 package for each component group
    # however one may require to ignore component group an
    # in this case you'll get 1 package for each component.
    if(CPACK_COMPONENTS_GROUPING STREQUAL "IGNORE")
      set(_ignoreGroups TRUE)
    else()
      set(_ignoreGroups FALSE)
    endif()
    _cpack_conan_setup_group_components(${_ignoreGroups})
  endif()
else()
  # CASE 3 : NON COMPONENT conan package.
  set(CPACK_CONAN_ORDINAL_MONOLITIC TRUE)
endif()

# Print some debug info
_cpack_conan_debug("---[CPack Conan Input Variables]---")
_cpack_conan_debug_var(CPACK_PACKAGE_NAME)
_cpack_conan_debug_var(CPACK_PACKAGE_VERSION)
_cpack_conan_debug_var(CPACK_TOPLEVEL_TAG)
_cpack_conan_debug_var(CPACK_TOPLEVEL_DIRECTORY)
_cpack_conan_debug_var(CPACK_TEMPORARY_DIRECTORY)
_cpack_conan_debug_var(CPACK_CONAN_GROUPS)
if(CPACK_CONAN_GROUPS)
  foreach(_group IN LISTS CPACK_CONAN_GROUPS)
    string(MAKE_C_IDENTIFIER "${_group}" _group_up)
    string(TOUPPER "${_group_up}" _group_up)
    _cpack_conan_debug_var(CPACK_CONAN_${_group_up}_GROUP_COMPONENTS)
  endforeach()
endif()
_cpack_conan_debug_var(CPACK_CONAN_COMPONENTS)
_cpack_conan_debug_var(CPACK_CONAN_ALL_IN_ONE)
_cpack_conan_debug_var(CPACK_CONAN_ORDINAL_MONOLITIC)
_cpack_conan_debug("-----------------------------------")