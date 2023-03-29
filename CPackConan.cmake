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

function(_cpack_conan_variable_fallback OUTPUT_VAR_NAME CONAN_VAR_NAME)
  # Debug output of input parameters
  if(ARGN)
    list(JOIN ARGN "', '" _va_args)
    set(_va_args ", ARGN: '${_va_args}'")
  endif()
  _cpack_conan_debug(
    "_cpack_conan_variable_fallback: "
    "OUTPUT_VAR_NAME='${OUTPUT_VAR_NAME}', "
    "CONAN_VAR_NAME='${CONAN_VAR_NAME}'"
    "${_va_args}"
  )

  # Parse arguments
  cmake_parse_arguments(PARSE_ARGV 0 _args "" "" "FALLBACK_VARS")

  # Make upper case name
  if(CPACK_CONAN_PACKAGE_COMPONENT)
    string(
      TOUPPER "${CPACK_CONAN_PACKAGE_COMPONENT}"
      CPACK_CONAN_PACKAGE_COMPONENT_UPPER
    )
  endif()

  # Try possible variants
  if(CPACK_CONAN_PACKAGE_COMPONENT AND NOT "${CPACK_CONAN_${CPACK_CONAN_PACKAGE_COMPONENT}_PACKAGE_${CONAN_VAR_NAME}}" STREQUAL "")
    set(_result "${CPACK_CONAN_${CPACK_CONAN_PACKAGE_COMPONENT}_PACKAGE_${CONAN_VAR_NAME}}")
    list(JOIN _result "\;" _result_str)
    _cpack_conan_debug(
      "  CPACK_CONAN_${CPACK_CONAN_PACKAGE_COMPONENT}_PACKAGE_${CONAN_VAR_NAME}: "
      "OUTPUT_VAR_NAME->${OUTPUT_VAR_NAME}='${_result_str}'"
    )
  elseif(CPACK_CONAN_PACKAGE_COMPONENT_UPPER AND NOT "${CPACK_CONAN_${CPACK_CONAN_PACKAGE_COMPONENT_UPPER}_PACKAGE_${CONAN_VAR_NAME}}" STREQUAL "")
    set(_result "${CPACK_CONAN_${CPACK_CONAN_PACKAGE_COMPONENT_UPPER}_PACKAGE_${CONAN_VAR_NAME}}")
    list(JOIN _result "\;" _result_str)
    _cpack_conan_debug(
      "  CPACK_CONAN_${CPACK_CONAN_PACKAGE_COMPONENT_UPPER}_PACKAGE_${CONAN_VAR_NAME}: "
      "OUTPUT_VAR_NAME->${OUTPUT_VAR_NAME}='${_result_str}'"
    )
  elseif(NOT "${CPACK_CONAN_PACKAGE_${CONAN_VAR_NAME}}" STREQUAL "")
    set(_result "${CPACK_CONAN_PACKAGE_${CONAN_VAR_NAME}}")
    list(JOIN _result "\;" _result_str)
    _cpack_conan_debug(
      "  CPACK_CONAN_PACKAGE_${CONAN_VAR_NAME}: "
      "OUTPUT_VAR_NAME->${OUTPUT_VAR_NAME}=`${_result_str}`"
    )
  else()
    foreach(_var IN LISTS _args_FALLBACK_VARS)
      _cpack_conan_debug("  Fallback: ${_var} ...")
      if(NOT "${_var}" STREQUAL "")
        _cpack_conan_debug("            ${_var}=`${${_var}}`")
        set(_result "${${_var}}")
        list(JOIN _result ", " _result_str)
        _cpack_conan_debug(
          "  ${_var}: OUTPUT_VAR_NAME->${OUTPUT_VAR_NAME}=`${_result_str}`"
        )
        break()
      endif()
    endforeach()
  endif()

  set(${OUTPUT_VAR_NAME} "${_result}" PARENT_SCOPE)
endfunction()

function(_cpack_conan_setup_condition_requirements)
  set(CPACK_CONAN_REQUIRES_CONDITIONS_HASHES "")
  _cpack_conan_variable_fallback(_requires REQUIRES)
  foreach(_require IN LISTS _requires)
    # Convert to upper-case C identifier
    string(MAKE_C_IDENTIFIER "${_require}" _require_up)
    string(TOUPPER "${_require_up}" _require_up)
    # Read possible conditions
    _cpack_conan_variable_fallback(_conditions REQUIRES_${_require_up}_OPTIONS_CONDITIONS)
    if(NOT "${_conditions}" STREQUAL "")
      foreach(_condition IN LISTS _conditions)
        # Convert to upper-case C identifier
        string(MAKE_C_IDENTIFIER "${_condition}" _condition_up)
        string(TOUPPER "${_condition_up}" _condition_up)
        # Read condition python expression
        _cpack_conan_variable_fallback(_condition_value REQUIRES_${_require_up}_OPTIONS_CONDITIONS_${_condition_up})
        # Create hash of python expression for sorting
        string(MD5 _condition_value_hash "${_condition_value}")
        string(TOUPPER "${_condition_value_hash}" _condition_value_hash)
        # Check if already in list
        if (NOT "${_condition_value_hash}" IN_LIST CPACK_CONAN_REQUIRES_CONDITIONS_HASHES)
          list(APPEND CPACK_CONAN_REQUIRES_CONDITIONS_HASHES "${_condition_value_hash}")
          set(CPACK_CONAN_REQUIRES_${_condition_value_hash} "${_condition_value}")
        endif()
        _cpack_conan_variable_fallback(_options REQUIRES_${_require_up}_OPTIONS)
        if(NOT "${_options}" STREQUAL "")
          foreach(_option IN LISTS _options)
            # Convert to upper-case C identifier
            string(MAKE_C_IDENTIFIER "${_option}" _option_up)
            string(TOUPPER "${_option_up}" _option_up)
            _cpack_conan_variable_fallback(_option_value REQUIRES_${_require_up}_OPTIONS_${_option_up}_CONDITIONS_${_condition_up})
            if(NOT "${_option_value}" STREQUAL "")
              list(APPEND CPACK_CONAN_REQUIRES_${_condition_value_hash}_OPTION_REQUIRE "${_require}")
              list(APPEND CPACK_CONAN_REQUIRES_${_condition_value_hash}_OPTION_NAMES "${_option}")
              list(APPEND CPACK_CONAN_REQUIRES_${_condition_value_hash}_OPTION_VALUES "${_option_value}")
            endif()
          endforeach()
        endif()
      endforeach()
    endif()
  endforeach()

  # Propagate variables to parent scope
  _cpack_conan_debug_var(CPACK_CONAN_REQUIRES_CONDITIONS_HASHES)
  set(CPACK_CONAN_REQUIRES_CONDITIONS_HASHES "${CPACK_CONAN_REQUIRES_CONDITIONS_HASHES}" PARENT_SCOPE)
  foreach(_condition_hash IN LISTS CPACK_CONAN_REQUIRES_CONDITIONS_HASHES)
    set(CPACK_CONAN_REQUIRES_${_condition_hash} "CPACK_CONAN_REQUIRES_${_condition_hash}" PARENT_SCOPE)
    _cpack_conan_debug_var(CPACK_CONAN_REQUIRES_${_condition_hash})
    set(CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_REQUIRE "${CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_REQUIRE}" PARENT_SCOPE)
    _cpack_conan_debug_var(CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_REQUIRE)
    set(CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_NAMES "${CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_NAMES}" PARENT_SCOPE)
    _cpack_conan_debug_var(CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_NAMES)
    set(CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_VALUES "${CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_VALUES}" PARENT_SCOPE)
    _cpack_conan_debug_var(CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_VALUES)
  endforeach()
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

foreach(_component IN LISTS CPACK_CONAN_COMPONENTS)
  set(CPACK_CONAN_PACKAGE_COMPONENT "${_component}")
  _cpack_conan_setup_condition_requirements()
endforeach()

find_program(conanexecutable "conan")
message(STATUS "${conanexecutable}")
