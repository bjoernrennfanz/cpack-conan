# cpack-conan
CPack wrapper for Conan to create C and C++ packages.

## Variables specific to CPack Conan generator

CPackConan may be used to create Conan packages using [CPack](https://cmake.org/cmake/help/latest/module/CPack.html#module:CPack).
CPackConan is a [CPack](https://cmake.org/cmake/help/latest/module/CPack.html#module:CPack) External generator therefore it uses the `CPACK_XXX`
variables used by [CPack](https://cmake.org/cmake/help/latest/module/CPack.html#module:CPack).

CPackConan has specific features which are controlled by the specific
`CPACK_CONAN_XXX` variables. In the "one per group" mode
(see [`CPACK_COMPONENTS_GROUPING`](https://cmake.org/cmake/help/latest/module/CPackComponent.html#variable:CPACK_COMPONENTS_GROUPING)), `<compName>` placeholder
in the variables below would contain a group name (uppercased and turned into
a "C" identifier).

List of CPackConan specific variables:

### CPACK_CONAN_COMPONENT_INSTALL

Enable component packaging for CPackConan

* Mandatory : NO
* Default   : OFF

### CPACK_CONAN_TOOL_SETTINGS

Settings that needed to build the package, overwriting the defaults (host machine).
See [Conan export-pkg command](https://docs.conan.io/1/reference/commands/creator/export-pkg.html) for more information.

* Mandatory : YES
* Default: None

### CPACK_CONAN_PACKAGE_NAME<br/>CPACK_CONAN_\<compName\>_PACKAGE_NAME

The Conan package name.

* Mandatory : YES
* Default   : [`CPACK_PACKAGE_NAME`](https://cmake.org/cmake/help/latest/module/CPack.html#variable:CPACK_PACKAGE_NAME)

### CPACK_CONAN_PACKAGE_VERSION<br/>CPACK_CONAN_\<compName\>_PACKAGE_VERSION

The Conan package version. See [Conan version attribute](https://docs.conan.io/1/reference/conanfile/attributes.html#version) for more information.

* Mandatory : YES
* Default   : [`CPACK_PACKAGE_VERSION`](https://cmake.org/cmake/help/latest/module/CPack.html#variable:CPACK_PACKAGE_VERSION)

### CPACK_CONAN_PACKAGE_DESCRIPTION<br/>CPACK_CONAN_\<compName\>_PACKAGE_DESCRIPTION

A long description of the package for UI display.

* Mandatory : YES
* Default   :
    - [`CPACK_COMPONENT_<compName>_DESCRIPTION`](https://cmake.org/cmake/help/latest/module/CPackComponent.html#variable:CPACK_COMPONENT_%3CcompName%3E_DESCRIPTION),
    - `CPACK_COMPONENT_GROUP_<groupName>_DESCRIPTION`,
    - [`CPACK_PACKAGE_DESCRIPTION`](https://cmake.org/cmake/help/latest/module/CPack.html#variable:CPACK_PACKAGE_DESCRIPTION)

### CPACK_CONAN_PACKAGE_LICENSE<br/>CPACK_CONAN_\<compName\>_PACKAGE_LICENSE

A software package license custom string or a [SPDX license identifier](https://spdx.github.io/spdx-spec/SPDX-license-list) such as
`MIT`, `BSD-3-Clause` or `LGPL-3.0-or-later`. See [Conan license attribute](https://docs.conan.io/1/reference/conanfile/attributes.html#license) for more information.

* Mandatory : NO
* Default   : None

### CPACK_CONAN_PACKAGE_AUTHOR<br/>CPACK_CONAN_\<compName\>_PACKAGE_AUTHOR

Intended to add information about the author, in case it is different from the Conan user.
It is possible that the Conan user is the name of an organization, project, company or group, 
and many users have permissions over that account. In this case, the author information can 
explicitly define who is the creator/maintainer of the package. 
See [Conan author attribute](https://docs.conan.io/1/reference/conanfile/attributes.html#author) for more information. 

* Mandatory : NO
* Default   : [`CPACK_PACKAGE_VENDOR`](https://cmake.org/cmake/help/latest/module/CPack.html#variable:CPACK_PACKAGE_VENDOR)

### CPACK_CONAN_PACKAGE_URL<br/>CPACK_CONAN_\<compName\>_PACKAGE_URL

A URL for the package´s home page. See [Conan url attribute](https://docs.conan.io/1/reference/conanfile/attributes.html#url) for more information.

* Mandatory : NO
* Default   : [`CPACK_PACKAGE_HOMEPAGE_URL`](https://cmake.org/cmake/help/latest/module/CPack.html#variable:CPACK_PACKAGE_HOMEPAGE_URL)

### CPACK_CONAN_PACKAGE_TOPICS<br/>CPACK_CONAN_\<compName\>_PACKAGE_TOPICS

A list of topics that describe the package and aid discoverability of packages through search and filtering.
See [Conan topics attribute](https://docs.conan.io/1/reference/conanfile/attributes.html#topics) for more information.

* Mandatory : NO
* Default   : None
 
### CPACK_CONAN_PACKAGE_GENERATORS<br/>CPACK_CONAN_\<compName\>_PACKAGE_GENERATORS

A list of Conan generators that are used on `install` command in your project folder.
Check the full [generators list](https://docs.conan.io/1/reference/generators.html#generators-reference).

* Mandatory : YES
* Default   : None

### CPACK_CONAN_PACKAGE_SETTINGS<br/>CPACK_CONAN_\<compName\>_PACKAGE_SETTINGS

A list of Conan settings that a used by Conan to calculate the binary package id.
See [Conan settings attribute](https://docs.conan.io/1/reference/conanfile/attributes.html#settings) for more information.

* Mandatory : YES
* Default   : None

### CPACK_CONAN_PACKAGE_REQUIRES<br/>CPACK_CONAN_\<compName\>_PACKAGE_REQUIRES

A list of package dependencies. See [Conan requires attribute](https://docs.conan.io/1/reference/conanfile/attributes.html#requires) for more information.

* Mandatory : NO
* Default   : None

### CPACK_CONAN_PACKAGE_REQUIRES_\<requireName\>\_VERSION<br/>CPACK_CONAN_\<compName\>\_PACKAGE_REQUIRES\_\<requireName\>_VERSION

A [version specification](https://docs.conan.io/1/reference/conanfile/attributes.html#version-ranges) for the particular dependency, where `<requireName>` 
is an item of the [requires list](#cpack_conan_package_requirescpack_conan_compname_package_requires) transformed with [`string(MAKE_C_IDENTIFIER)`](https://cmake.org/cmake/help/latest/command/string.html#command:string) command.

* Mandatory : NO
* Default   : None

### CPACK_CONAN_PACKAGE_REQUIRES_\<requireName\>_OPTIONS<br/>CPACK\_CONAN\_\<compName\>\_PACKAGE_REQUIRES\_\<requireName\>_OPTIONS

A list of option names for the particular dependency, where `<requireName>` is an item of the [requires list](#cpack_conan_package_requirescpack_conan_compname_package_requires) transformed with [`string(MAKE_C_IDENTIFIER)`](https://cmake.org/cmake/help/latest/command/string.html#command:string) command.

* Mandatory : NO
* Default   : None

### CPACK_CONAN_PACKAGE_REQUIRES_\<requireName\>\_OPTIONS\_\<optionName\><br/>CPACK_CONAN\_\<compName\>\_PACKAGE_REQUIRES_\<requireName\>\_OPTIONS\_\<optionName\>

The value for the particular dependency option, where `<requireName>` is an item of the [requires list](#cpack_conan_package_requirescpack_conan_compname_package_requires) 
and `<optionName>` is an item of the [requires options list](#cpack_conan_package_requires_requirename_optionscpack_conan_compname_package_requires_requirename_options)
transformed with [`string(MAKE_C_IDENTIFIER)`](https://cmake.org/cmake/help/latest/command/string.html#command:string) command.

* Mandatory : NO
* Default   : None

### CPACK_CONAN_PACKAGE_REQUIRES_\<requireName\>_OPTIONS_CONDITIONS<br/>CPACK_CONAN\_\<compName\>\_PACKAGE_REQUIRES\_\<requireName\>_OPTIONS_CONDITIONS

A list of names for the particular dependency option condition, where `<requireName>` is an item of the [requires list](#cpack_conan_package_requirescpack_conan_compname_package_requires) 
transformed with [`string(MAKE_C_IDENTIFIER)`](https://cmake.org/cmake/help/latest/command/string.html#command:string) command.

* Mandatory : NO
* Default   : None

### CPACK_CONAN_PACKAGE_REQUIRES_\<requireName\>\_OPTIONS_CONDITIONS_\<conditionName\><br/>CPACK_CONAN_\<compName\>\_PACKAGE_REQUIRES\_\<requireName\>\_OPTIONS_CONDITIONS\_\<conditionName\>

A python condition that is injected into the generated Conan recipe and used to create a conditional block for the particular dependency option, 
where `<requireName>` is an item of the [requires list](#cpack_conan_package_requirescpack_conan_compname_package_requires)
and `<conditionName>` is an item of the [conditional requires options list](#cpack_conan_package_requires_requirename_options_conditionscpack_conan_compname_package_requires_requirename_options_conditions) and
transformed with [`string(MAKE_C_IDENTIFIER)`](https://cmake.org/cmake/help/latest/command/string.html#command:string) command.

* Mandatory : NO
* Default   : None

### CPACK_CONAN_PACKAGE_REQUIRES_\<requireName\>\_OPTIONS\_\<optionName\>\_CONDITIONS\_\<conditionName\><br/>CPACK_CONAN_\<compName\>\_PACKAGE_REQUIRES\_\<requireName\>\_OPTIONS_\<optionName\>\_CONDITIONS\_\<conditionName\>

The value for the conditional particular dependency option, where `<requireName>` is an item of the [requires list](#cpack_conan_package_requirescpack_conan_compname_package_requires)
, `<optionName>` is an item of the [requires options list](#cpack_conan_package_requires_requirename_optionscpack_conan_compname_package_requires_requirename_options) and
`<conditionName>` is an item of the [conditional requires options list](#cpack_conan_package_requires_requirename_options_conditionscpack_conan_compname_package_requires_requirename_options_conditions) and
transformed with [`string(MAKE_C_IDENTIFIER)`](https://cmake.org/cmake/help/latest/command/string.html#command:string) command.

* Mandatory : NO
* Default   : None

### CPACK_CONAN_PACKAGE_REFERENCE<br/>CPACK_CONAN_\<compName\>_PACKAGE_REFERENCE

The user/channel of the generated package. See [Conan export-pkg command](https://docs.conan.io/1/reference/commands/creator/export-pkg.html) for more information.

* Mandatory : NO
* Default   : None

### CPACK_CONAN_SKIP_EXPORT<br/>CPACK_CONAN_\<compName\>_SKIP_EXPORT

Skips the conan export step. The conan files will be generated for later use.

* Mandatory : NO
* Default   : OFF

### CPACK_CONAN_EXPORT_PACKAGE_GENERATION_INFO

Store the package generation info and generated conan files to generate the conan packages at a later point.
A uniquely named directory is created inside the CPACK_PACKAGE_DIRECTORY. It contains all generated conan files and
a file named "package_generation_info.json". 

* Mandatory : NO
* Default   : OFF

#### Format of package_generation_info.json

The file may contain multiple fields at the top level. One per component/group contained in the generated package. The
fields are named after the respective component. A component contains three fields:
* ConanFile: The name of the conan file used to create the package.
* Archive: The name of the archive containing the package contents.
* CmdArgs: The list of command line arguments for the conan export command.
Example:
```json
{
    "Adapters":
    {
      "ConanFile": "VtoolCreatorAdapters.py",
      "Archive": "VToolCreatorAdapters-0.9.0.65432-snapshot-darwin-x86_64",
      "CmdArgs": ["snapshot/potentially-public","--settings","build_type=Release","--settings","compiler=apple-clang","--settings","compiler.version=13","--settings","compiler.libcxx=libc++","--settings","arch=x86_64"]
    }
}
```
To export the conan package at a later point you have to iterate over all components in the file, unpack the archive
into a folder that has the same name as the component, place the conan file next to this folder and call:
```bash
conan export-pkg --force [ConanFile] [CmdArgsStr]
```
Replace ConanFile with the path to the conan file and CmdArgsStr with all elements of CmdArgs joined with a space.
Example:
```bash
conan export-pkg --force  VtoolCreatorAdapters.py snapshot/potentially-public --settings build_type=Release --settings compiler=apple-clang --settings compiler.version=13 --settings compiler.libcxx=libc++ --settings arch=x86_64
```