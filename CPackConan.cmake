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
      "OUTPUT_VAR_NAME->${OUTPUT_VAR_NAME}='${_result_str}'"
    )
  else()
    foreach(_var IN LISTS _args_FALLBACK_VARS)
      _cpack_conan_debug("  Fallback: ${_var} ...")
      if(${_var})
        _cpack_conan_debug("            ${_var}='${${_var}}'")
        set(_result "${${_var}}")
        list(JOIN _result ", " _result_str)
        _cpack_conan_debug(
          "  ${_var}: OUTPUT_VAR_NAME->${OUTPUT_VAR_NAME}='${_result_str}'"
        )
        break()
      endif()
    endforeach()
  endif()

  if (NOT "${_result}" STREQUAL "")
    set(${OUTPUT_VAR_NAME} "${_result}" PARENT_SCOPE)
  endif()
endfunction()

function(_cpack_conan_setup_condition_requirements)
  unset(CPACK_CONAN_REQUIRES_CONDITIONS_HASHES)
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
          # Add condition hash to list
          list(APPEND CPACK_CONAN_REQUIRES_CONDITIONS_HASHES "${_condition_value_hash}")
          set(CPACK_CONAN_REQUIRES_${_condition_value_hash} "${_condition_value}")
          # Reset list items
          set(CPACK_CONAN_REQUIRES_${_condition_value_hash}_OPTION_REQUIRE "")
          set(CPACK_CONAN_REQUIRES_${_condition_value_hash}_OPTION_NAMES "")
          set(CPACK_CONAN_REQUIRES_${_condition_value_hash}_OPTION_VALUES "")
        endif()
        _cpack_conan_variable_fallback(_options REQUIRES_${_require_up}_OPTIONS)
        if(NOT "${_options}" STREQUAL "")
          foreach(_option IN LISTS _options)
            # Convert to upper-case C identifier
            string(MAKE_C_IDENTIFIER "${_option}" _option_up)
            string(TOUPPER "${_option_up}" _option_up)
            _cpack_conan_variable_fallback(_option_value REQUIRES_${_require_up}_OPTIONS_${_option_up}_CONDITIONS_${_condition_up})
            if(NOT "${_option_value}" STREQUAL "")
              # Append to lists with needed condition values
              list(APPEND CPACK_CONAN_REQUIRES_${_condition_value_hash}_OPTION_REQUIRE "${_require}")
              list(APPEND CPACK_CONAN_REQUIRES_${_condition_value_hash}_OPTION_NAMES "${_option}")
              list(APPEND CPACK_CONAN_REQUIRES_${_condition_value_hash}_OPTION_VALUES "${_option_value}")
            endif()
            unset(_option_value)
          endforeach()
        endif()
        unset(_options)
      endforeach()
    endif()
    unset(_conditions)
  endforeach()

  # Propagate variables to parent scope
  if(NOT "${CPACK_CONAN_REQUIRES_CONDITIONS_HASHES}" STREQUAL "")
    _cpack_conan_debug_var(CPACK_CONAN_REQUIRES_CONDITIONS_HASHES)
    set(CPACK_CONAN_REQUIRES_CONDITIONS_HASHES "${CPACK_CONAN_REQUIRES_CONDITIONS_HASHES}" PARENT_SCOPE)
    foreach(_condition_hash IN LISTS CPACK_CONAN_REQUIRES_CONDITIONS_HASHES)
      set(CPACK_CONAN_REQUIRES_${_condition_hash} "${CPACK_CONAN_REQUIRES_${_condition_hash}}" PARENT_SCOPE)
      _cpack_conan_debug_var(CPACK_CONAN_REQUIRES_${_condition_hash})
      set(CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_REQUIRE "${CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_REQUIRE}" PARENT_SCOPE)
      _cpack_conan_debug_var(CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_REQUIRE)
      set(CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_NAMES "${CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_NAMES}" PARENT_SCOPE)
      _cpack_conan_debug_var(CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_NAMES)
      set(CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_VALUES "${CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_VALUES}" PARENT_SCOPE)
      _cpack_conan_debug_var(CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_VALUES)
    endforeach()
  endif()
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

function(_cpack_conan_make_package_method)
  set(_method_lines "    def package(self):\n")
  foreach(_component IN LISTS ARGN)
    string(APPEND _method_lines "        copy(self, '*', src=os.path.join(self.source_folder, '${_component}'), dst=self.package_folder)\n")
  endforeach()
  string(APPEND _method_lines "\n")
  set(_CPACK_CONAN_PACKAGE_METHOD "${_method_lines}" PARENT_SCOPE)
endfunction()

function(_cpack_conan_make_configure_method)
  unset(_first_require)
  set(_CPACK_CONAN_REQUIRES_CONDITIONS_HASHES)
  foreach(_component IN LISTS ARGN)
    # Temporary set 'CPACK_CONAN_PACKAGE_COMPONENT' to the current
    # component to properly collect possible combinations
    set(CPACK_CONAN_PACKAGE_COMPONENT ${_component})
    _cpack_conan_variable_fallback(_requires REQUIRES)
    foreach(_require IN LISTS _requires)
      # Convert to upper-case C identifier
      string(MAKE_C_IDENTIFIER "${_require}" _require_up)
      string(TOUPPER "${_require_up}" _require_up)
      _cpack_conan_variable_fallback(_options REQUIRES_${_require_up}_OPTIONS)
      if (NOT "${_options}" STREQUAL "")
        # Loop over all possible options
        foreach(_option IN LISTS _options)
          if (NOT _first_require)
            set(_method_lines "    def configure(self):\n")
            set(_first_require TRUE)
          endif()
          # Convert to upper-case C identifier
          string(MAKE_C_IDENTIFIER "${_option}" _option_up)
          string(TOUPPER "${_option_up}" _option_up)
          _cpack_conan_variable_fallback(_option_value REQUIRES_${_require_up}_OPTIONS_${_option_up})
          if(NOT "${_option_value}" STREQUAL "")
            if (NOT _first_option)
              string(APPEND _method_lines "        # Configure ${_require}\n")
              set(_first_option TRUE)
            endif()
            string(APPEND _method_lines "        self.options['${_require}'].${_option} = ${_option_value}\n")
          endif()
          unset(_option_value)
        endforeach()
        string(APPEND _method_lines "\n")
      endif()
      unset(_options)
      unset(_first_option)
    endforeach()
    # Determine possible condition for current component
    _cpack_conan_setup_condition_requirements()
    if(NOT "${CPACK_CONAN_REQUIRES_CONDITIONS_HASHES}" STREQUAL "")
      list(APPEND _CPACK_CONAN_REQUIRES_CONDITIONS_HASHES "${CPACK_CONAN_REQUIRES_CONDITIONS_HASHES}")
      list(REMOVE_DUPLICATES _CPACK_CONAN_REQUIRES_CONDITIONS_HASHES)
    endif()
    unset(CPACK_CONAN_PACKAGE_COMPONENT)
  endforeach()
  # Add conditions when found
  if(NOT "${_CPACK_CONAN_REQUIRES_CONDITIONS_HASHES}" STREQUAL "")
    unset(_first_condition)
    string(APPEND _method_lines "        # Configure condition specific options\n")
    foreach(_condition_hash IN LISTS _CPACK_CONAN_REQUIRES_CONDITIONS_HASHES)
      _cpack_conan_debug_var(CPACK_CONAN_REQUIRES_${_condition_hash})
      if (NOT _first_condition)
        string(APPEND _method_lines "        if ${CPACK_CONAN_REQUIRES_${_condition_hash}}:\n")
        set(_first_condition TRUE)
      else()
        string(APPEND _method_lines "        elif ${CPACK_CONAN_REQUIRES_${_condition_hash}}:\n")
      endif()
      set(_condition_option_index 0)
      list(LENGTH CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_REQUIRE _condition_option_length)
      foreach(_option_require IN LISTS CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_REQUIRE)
        # Get condition option and values
        list(GET CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_NAMES "${_condition_option_index}" _option_name)
        list(GET CPACK_CONAN_REQUIRES_${_condition_hash}_OPTION_VALUES "${_condition_option_index}" _option_value)
        string(APPEND _method_lines "            self.options['${_option_require}'].${_option_name} = ${_option_value}\n")
        # Increment index
        MATH(EXPR _condition_option_index "${_condition_option_index} + 1")
      endforeach()
    endforeach()
  endif()
  set(_CPACK_CONAN_CONFIGURE_METHOD "${_method_lines}" PARENT_SCOPE)
endfunction()

function(_cpack_conan_make_requirements_method)
  unset(_first_require)
  foreach(_component IN LISTS ARGN)
    # Temporary set 'CPACK_CONAN_PACKAGE_COMPONENT' to the current
    # component to properly collect possible combinations
    set(CPACK_CONAN_PACKAGE_COMPONENT ${_component})
    _cpack_conan_variable_fallback(_requires REQUIRES)
    foreach(_require IN LISTS _requires)
      if (NOT _first_require)
        set(_method_lines "    def requirements(self):\n")
        string(APPEND _method_lines "        # Setup needed dependencies\n")
        set(_first_require TRUE)
      endif()
      # Convert to upper-case C identifier
      string(MAKE_C_IDENTIFIER "${_require}" _require_up)
      string(TOUPPER "${_require_up}" _require_up)
      _cpack_conan_variable_fallback(_require_version REQUIRES_${_require_up}_VERSION)
      string(APPEND _method_lines "        self.requires('${_require}/${_require_version}')\n")
    endforeach()
    unset(CPACK_CONAN_PACKAGE_COMPONENT)
  endforeach()
  set(_CPACK_CONAN_REQUIREMENTS_METHOD "${_method_lines}" PARENT_SCOPE)
endfunction()

function(_cpack_conan_generate_class_name OUTPUT_VAR_NAME CONAN_PACKAGE_NAME)
  # Debug output of input parameters
  _cpack_conan_debug(
    "_cpack_conan_generate_class_name: "
    "OUTPUT_VAR_NAME='${OUTPUT_VAR_NAME}', "
    "CONAN_PACKAGE_NAME='${CONAN_PACKAGE_NAME}'"
  )
  # Convert to C identifier an split into tokens
  string(MAKE_C_IDENTIFIER "${CONAN_PACKAGE_NAME}" _CONAN_PACKAGE_NAME_C)
  string(REPLACE "_" ";" _CONAN_PACKAGE_NAME_TOKENS "${_CONAN_PACKAGE_NAME_C}")
  # Capitalize first letters of C identifier
  set(_result)
  foreach(_token IN LISTS _CONAN_PACKAGE_NAME_TOKENS)
    string(SUBSTRING ${_token} 0 1 _token_first_letter)
    string(TOUPPER ${_token_first_letter} _token_first_letter)
    string(REGEX REPLACE "^.(.*)" "${_token_first_letter}\\1" _token_cap "${_token}")
    string(APPEND _result "${_token_cap}")
  endforeach()
  _cpack_conan_debug(
    "  OUTPUT_VAR_NAME->${OUTPUT_VAR_NAME}='${_result}'"
  )
  set(${OUTPUT_VAR_NAME} "${_result}" PARENT_SCOPE)
endfunction()

function(_cpack_conan_make_conanfile CONAN_PACKAGE_CONANFILE_PY)
  set(_conanfile_py)
  # Make a variable with upper-cased component name
  if(CPACK_CONAN_PACKAGE_COMPONENT)
    string(TOUPPER "${CPACK_CONAN_PACKAGE_COMPONENT}" CPACK_CONAN_PACKAGE_COMPONENT_UPPER)
  endif()

  # Set mandatory attributes of conanfile.py
  # https://docs.conan.io/en/1.46/reference/conanfile/attributes.html
  if(CPACK_CONAN_PACKAGE_COMPONENT)
    if(CPACK_CONAN_${CPACK_CONAN_PACKAGE_COMPONENT_UPPER}_PACKAGE_NAME)
      string(TOLOWER "${CPACK_CONAN_${CPACK_CONAN_PACKAGE_COMPONENT_UPPER}_PACKAGE_NAME}" CPACK_CONAN_PACKAGE_NAME)
    elseif(NOT CPACK_CONAN_PACKAGE_COMPONENT STREQUAL "")
      string(TOLOWER "${CPACK_PACKAGE_NAME}-${CPACK_CONAN_PACKAGE_COMPONENT}" CPACK_CONAN_PACKAGE_NAME)
    else()
      string(TOLOWER "${CPACK_PACKAGE_NAME}" CPACK_CONAN_PACKAGE_NAME)
    endif()
  elseif(NOT CPACK_CONAN_PACKAGE_NAME)
    string(TOLOWER "${CPACK_PACKAGE_NAME}" CPACK_CONAN_PACKAGE_NAME)
  endif()
  _cpack_conan_variable_fallback(
    CPACK_CONAN_PACKAGE_VERSION VERSION
    FALLBACK_VARS
      CPACK_PACKAGE_VERSION
  )
  _cpack_conan_variable_fallback(
    CPACK_CONAN_PACKAGE_DESCRIPTION DESCRIPTION
    FALLBACK_VARS
      CPACK_COMPONENT_${CPACK_CONAN_PACKAGE_COMPONENT}_DESCRIPTION
      CPACK_COMPONENT_${CPACK_CONAN_PACKAGE_COMPONENT_UPPER}_DESCRIPTION
      CPACK_COMPONENT_GROUP_${CPACK_CONAN_PACKAGE_COMPONENT_UPPER}_DESCRIPTION
      CPACK_PACKAGE_DESCRIPTION
  )
  _cpack_conan_variable_fallback(
    CPACK_CONAN_PACKAGE_AUTHORS AUTHORS
    FALLBACK_VARS
      CPACK_PACKAGE_VENDOR
  )
  _cpack_conan_variable_fallback(
    CPACK_CONAN_PACKAGE_URL URL
    FALLBACK_VARS
      CPACK_PACKAGE_HOMEPAGE_URL
  )
  _cpack_conan_variable_fallback(CPACK_CONAN_PACKAGE_TOPICS TOPICS)
  _cpack_conan_variable_fallback(CPACK_CONAN_PACKAGE_LICENSE LICENSE)
  _cpack_conan_variable_fallback(CPACK_CONAN_PACKAGE_SETTINGS SETTINGS)
  _cpack_conan_variable_fallback(CPACK_CONAN_PACKAGE_GENERATORS GENERATORS)

  # Generate class name
  _cpack_conan_generate_class_name(CPACK_CONAN_PACKAGE_CLASS "${CPACK_CONAN_PACKAGE_NAME}")

  string(APPEND _conanfile_py "import os\n")
  string(APPEND _conanfile_py "from conan import ConanFile\n")
  string(APPEND _conanfile_py "from conan.tools.files import copy\n")

  string(APPEND _conanfile_py "\n\nclass ${CPACK_CONAN_PACKAGE_CLASS}ConanFile(ConanFile):\n")
  string(APPEND _conanfile_py "    name = '${CPACK_CONAN_PACKAGE_NAME}'\n")
  string(APPEND _conanfile_py "    description = '${CPACK_CONAN_PACKAGE_DESCRIPTION}'\n")
  if(CPACK_CONAN_PACKAGE_AUTHORS)
    string(APPEND _conanfile_py "    author = '${CPACK_CONAN_PACKAGE_AUTHORS}'\n")
  endif()
  if(CPACK_CONAN_PACKAGE_TOPICS)
    list(JOIN CPACK_CONAN_PACKAGE_TOPICS "', '" _CPACK_CONAN_PACKAGE_TOPICS_ITEM_STR)
    string(APPEND _conanfile_py "    topics = ('${_CPACK_CONAN_PACKAGE_TOPICS_ITEM_STR}')\n")
  endif()
  if (CPACK_CONAN_PACKAGE_URL)
    string(APPEND _conanfile_py "    url = '${CPACK_CONAN_PACKAGE_URL}'\n")
  endif()
  if (CPACK_CONAN_PACKAGE_LICENSE)
    string(APPEND _conanfile_py "    license = '${CPACK_CONAN_PACKAGE_LICENSE}'\n")
  endif()

  list(JOIN CPACK_CONAN_PACKAGE_SETTINGS "', '" _CPACK_CONAN_PACKAGE_SETTINGS_STR)
  string(APPEND _conanfile_py "    settings = '${_CPACK_CONAN_PACKAGE_SETTINGS_STR}'\n")
  list(JOIN CPACK_CONAN_PACKAGE_GENERATORS "', '" _CPACK_CONAN_PACKAGE_GENERATORS_STR)
  string(APPEND _conanfile_py "    generators = '${_CPACK_CONAN_PACKAGE_GENERATORS_STR}'\n")
  string(APPEND _conanfile_py "    version = '${CPACK_CONAN_PACKAGE_VERSION}'\n\n")

  if (_CPACK_CONAN_CONFIGURE_METHOD)
    string(APPEND _conanfile_py "${_CPACK_CONAN_CONFIGURE_METHOD}\n")
  endif()
  if (_CPACK_CONAN_REQUIREMENTS_METHOD)
    string(APPEND _conanfile_py "${_CPACK_CONAN_REQUIREMENTS_METHOD}\n")
  endif()
  string(APPEND _conanfile_py "${_CPACK_CONAN_PACKAGE_METHOD}\n")

  _cpack_conan_debug("Create '${CPACK_TEMPORARY_DIRECTORY}/${CPACK_CONAN_PACKAGE_CLASS}.py' file...")
  file(CONFIGURE
    OUTPUT "${CPACK_TEMPORARY_DIRECTORY}/${CPACK_CONAN_PACKAGE_CLASS}.py"
    CONTENT "${_conanfile_py}" @ONLY
    NEWLINE_STYLE LF
  )
  set(${CONAN_PACKAGE_CONANFILE_PY} "${CPACK_TEMPORARY_DIRECTORY}/${CPACK_CONAN_PACKAGE_CLASS}.py" PARENT_SCOPE)
endfunction()

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

find_program(CONAN_EXECUTABLE conan)
_cpack_conan_debug_var(CONAN_EXECUTABLE)
if(NOT CONAN_EXECUTABLE)
  message(FATAL_ERROR "Conan executable not found")
endif()

if(CPACK_CONAN_TOOL_SETTINGS)
  set(CPACK_CONAN_TOOL_COMMANDLINE_SETTINGS)
  foreach(_setting IN LISTS CPACK_CONAN_TOOL_SETTINGS)
    list(APPEND CPACK_CONAN_TOOL_COMMANDLINE_SETTINGS "--settings")
    list(APPEND CPACK_CONAN_TOOL_COMMANDLINE_SETTINGS "${_setting}")
  endforeach()
endif()

if(CPACK_CONAN_ORDINAL_MONOLITIC)
  # Meaning to pack all installed files into a single package
  _cpack_conan_debug("---[Making an ordinal monolitic package]---")
  _cpack_conan_make_conanfile(_CPACK_CONAN_CONANFILE)
elseif(CPACK_CONAN_ALL_IN_ONE)
  # Meaning to pack all installed components into a single package
  _cpack_conan_debug("---[Making a monolitic package from installed components]---")
  _cpack_conan_make_package_method(${CPACK_CONAN_COMPONENTS})
  _cpack_conan_make_configure_method(${CPACK_CONAN_COMPONENTS})
  _cpack_conan_make_requirements_method(${CPACK_CONAN_COMPONENTS})
  _cpack_conan_make_conanfile(_CPACK_CONAN_CONANFILE)
  _cpack_conan_variable_fallback(CPACK_CONAN_PACKAGE_REFERENCE REFERENCE)
  set(CPACK_CONAN_PACKAGE_COMPONENTS ${CPACK_CONAN_COMPONENTS})
  if(CPACK_CONAN_EXTERNAL_PRE_PACKAGE_SCRIPT)
    include("${CPACK_CONAN_EXTERNAL_PRE_PACKAGE_SCRIPT}")
  endif()
  set(CPACK_CONAN_TOOL_COMMANDLINE_ARGS ${CPACK_CONAN_PACKAGE_REFERENCE})
  list(APPEND CPACK_CONAN_TOOL_COMMANDLINE_ARGS ${CPACK_CONAN_TOOL_COMMANDLINE_SETTINGS})
  if(CPACK_CONAN_PACKAGE_DEBUG)
    list(JOIN CPACK_CONAN_TOOL_COMMANDLINE_ARGS " " CPACK_CONAN_TOOL_COMMANDLINE_ARGS_STRING)
    _cpack_conan_debug("Executing: ${CONAN_EXECUTABLE} export-pkg --force ${_CPACK_CONAN_CONANFILE} ${CPACK_CONAN_TOOL_COMMANDLINE_ARGS_STRING}")
  endif()
  execute_process(
    COMMAND "${CONAN_EXECUTABLE}" export-pkg --force ${_CPACK_CONAN_CONANFILE} ${CPACK_CONAN_TOOL_COMMANDLINE_ARGS}
    WORKING_DIRECTORY "${CPACK_TEMPORARY_DIRECTORY}"
  )
  if(CPACK_CONAN_EXTERNAL_POST_PACKAGE_SCRIPT)
    include("${CPACK_CONAN_EXTERNAL_POST_PACKAGE_SCRIPT}")
  endif()
  unset(CPACK_CONAN_PACKAGE_COMPONENTS)
else()
  # First build grouped components
  if(CPACK_CONAN_GROUPS)
    _cpack_conan_debug("---[Making grouped component(s) package(s)]---")
    foreach(_group IN LISTS CPACK_CONAN_GROUPS)
      _cpack_conan_debug("Starting to make the package for group '${_group}'")
      string(MAKE_C_IDENTIFIER "${_group}" _group_up)
      string(TOUPPER "${_group_up}" _group_up)
      # Create a conanfile.py which includes all components in the current group
      unset(_CPACK_CONAN_PACKAGE_METHOD)
      unset(_CPACK_CONAN_CONFIGURE_METHOD)
      _cpack_conan_make_package_method(${CPACK_CONAN_${_group_up}_GROUP_COMPONENTS})
      _cpack_conan_make_configure_method(${_group})
      _cpack_conan_make_requirements_method(${_group})
      # Temporary set 'CPACK_CONAN_PACKAGE_COMPONENT' to the group name
      # to properly collect various per group settings
      set(CPACK_CONAN_PACKAGE_COMPONENT ${_group})
      set(CPACK_CONAN_PACKAGE_COMPONENTS ${CPACK_CONAN_${_group_up}_GROUP_COMPONENTS})
      _cpack_conan_make_conanfile(_CPACK_CONAN_CONANFILE)
      _cpack_conan_variable_fallback(CPACK_CONAN_PACKAGE_REFERENCE REFERENCE)
      if(CPACK_CONAN_EXTERNAL_PRE_PACKAGE_SCRIPT)
        include("${CPACK_CONAN_EXTERNAL_PRE_PACKAGE_SCRIPT}")
      endif()
      unset(CPACK_CONAN_PACKAGE_COMPONENT)
      set(CPACK_CONAN_TOOL_COMMANDLINE_ARGS ${CPACK_CONAN_PACKAGE_REFERENCE})
      list(APPEND CPACK_CONAN_TOOL_COMMANDLINE_ARGS ${CPACK_CONAN_TOOL_COMMANDLINE_SETTINGS})
      if(CPACK_CONAN_PACKAGE_DEBUG)
        list(JOIN CPACK_CONAN_TOOL_COMMANDLINE_ARGS " " CPACK_CONAN_TOOL_COMMANDLINE_ARGS_STRING)
        _cpack_conan_debug("Executing: ${CONAN_EXECUTABLE} export-pkg --force ${_CPACK_CONAN_CONANFILE} ${CPACK_CONAN_TOOL_COMMANDLINE_ARGS_STRING}")
      endif()
      execute_process(
        COMMAND "${CONAN_EXECUTABLE}" export-pkg --force ${_CPACK_CONAN_CONANFILE} ${CPACK_CONAN_TOOL_COMMANDLINE_ARGS}
        WORKING_DIRECTORY "${CPACK_TEMPORARY_DIRECTORY}"
      )
      if(CPACK_CONAN_EXTERNAL_POST_PACKAGE_SCRIPT)
        include("${CPACK_CONAN_EXTERNAL_POST_PACKAGE_SCRIPT}")
      endif()
      unset(CPACK_CONAN_PACKAGE_COMPONENTS)
    endforeach()
  endif()
  # Second build single components
  if(CPACK_CONAN_COMPONENTS)
    _cpack_conan_debug("---[Making single-component(s) package(s)]---")
    foreach(_component IN LISTS CPACK_CONAN_COMPONENTS)
      _cpack_conan_debug("Starting to make the package for component '${_component}'")
      # Create a conanfile.py which includes includes only given component
      unset(_CPACK_CONAN_PACKAGE_METHOD)
      unset(_CPACK_CONAN_CONFIGURE_METHOD)
      _cpack_conan_make_package_method(${_component})
      _cpack_conan_make_configure_method(${_component})
      _cpack_conan_make_requirements_method(${_component})
      # Temporary set 'CPACK_CONAN_PACKAGE_COMPONENT' to the current
      # component name to properly collect various per component settings
      set(CPACK_CONAN_PACKAGE_COMPONENT ${_component})
      set(CPACK_CONAN_PACKAGE_COMPONENTS ${_component})
      _cpack_conan_make_conanfile(_CPACK_CONAN_CONANFILE)
      _cpack_conan_variable_fallback(CPACK_CONAN_PACKAGE_REFERENCE REFERENCE)
      if(CPACK_CONAN_EXTERNAL_PRE_PACKAGE_SCRIPT)
        include("${CPACK_CONAN_EXTERNAL_PRE_PACKAGE_SCRIPT}")
      endif()
      unset(CPACK_CONAN_PACKAGE_COMPONENT)
      set(CPACK_CONAN_TOOL_COMMANDLINE_ARGS ${CPACK_CONAN_PACKAGE_REFERENCE})
      list(APPEND CPACK_CONAN_TOOL_COMMANDLINE_ARGS ${CPACK_CONAN_TOOL_COMMANDLINE_SETTINGS})
      if(CPACK_CONAN_PACKAGE_DEBUG)
        list(JOIN CPACK_CONAN_TOOL_COMMANDLINE_ARGS " " CPACK_CONAN_TOOL_COMMANDLINE_ARGS_STRING)
        _cpack_conan_debug("Executing: ${CONAN_EXECUTABLE} export-pkg --force ${_CPACK_CONAN_CONANFILE} ${CPACK_CONAN_TOOL_COMMANDLINE_ARGS_STRING}")
      endif()
      execute_process(
        COMMAND "${CONAN_EXECUTABLE}" export-pkg --force ${_CPACK_CONAN_CONANFILE} ${CPACK_CONAN_TOOL_COMMANDLINE_ARGS}
        WORKING_DIRECTORY "${CPACK_TEMPORARY_DIRECTORY}"
      )
      if(CPACK_CONAN_EXTERNAL_POST_PACKAGE_SCRIPT)
        include("${CPACK_CONAN_EXTERNAL_POST_PACKAGE_SCRIPT}")
      endif()
      unset(CPACK_CONAN_PACKAGE_COMPONENTS)
    endforeach()
  endif()
endif()