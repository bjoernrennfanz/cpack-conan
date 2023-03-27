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

### CPACK_CONAN_PACKAGE_NAME<br/>CPACK_CONAN_<compName>_PACKAGE_NAME

The Conan package name.

* Mandatory : YES
* Default   : `CPACK_PACKAGE_NAME`

### CPACK_CONAN_PACKAGE_VERSION<br/>CPACK_CONAN_\<compName\>_PACKAGE_VERSION

The Conan package version.

* Mandatory : YES
* Default   : `CPACK_PACKAGE_VERSION`
