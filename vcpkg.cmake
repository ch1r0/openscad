include($ENV{CMAKE_TOOLCHAIN_FILE})

if (NOT DEFINED openscad_vcpkg_override)
  set(openscad_vcpkg_override 1)

  # Override find_library and replace the library path to contain both debug and release versions
  # HACK: redefine both find_library and _find_library to prevent stack overflow caused by double redefinitions of find_library

  message(STATUS "[vcpkg] override find_library and _find_library")

  # Redefine find_library - the built-in find_library command becomes _find_library
  function(find_library)
    z_vcpkg_function_arguments(ARGS)
    __find_library(${ARGS}) # CMake's built-in find_library command
    message(STATUS "[vcpkg] find_library ${ARGV0} -> ${${ARGV0}}")
    set(OutVar ${ARGV0})

    # Override if out variable is ..._LIBRARY. Some vcpkg libraries already requests _LIBRARY_DEBUG and _LIBRARY_RELEASE separate. PkgConfig uses a different method too.
    list(APPEND included "^.*_LIBRARY$")

    # Exclude some of the libraries with their own fixes conflicting with ours
    list(APPEND excluded "Iconv_LIBRARY")
    list(APPEND excluded "Intl_LIBRARY")

    set(matched FALSE)
    foreach (pattern IN ITEMS ${included})
      if (OutVar MATCHES ${pattern})
        set(matched TRUE)
	foreach (antipattern IN ITEMS ${excluded})
          if (OutVar MATCHES ${antipattern})
            set(matched FALSE)
            break()
          endif()
        endforeach()
        break()
      endif()
    endforeach()

    # if XXX_LIBRARY has debug/lib/ in it - vcpkg is used and library debug/release build has same name - need to fix the result
    if (NOT DEFINED ${OutVar}_FIXED AND matched AND ${OutVar} MATCHES "[\\\/]debug[\\\/]lib[\\\/][^\\\/]+$")
      # Current path is for the debug lib (_LIBRARY_DEBUG)
      set(${OutVar}_DEBUG ${${OutVar}})

      # Drop /debug from the path and use it for the release lib (_LIBRARY_RELEASE)
      # NOTE: this method does not work if debug and release libraries are named differently. However if it's the case, their vcpkg
      # distribution should have already been updated to retrieve debug and release libs separately.
      string(REGEX REPLACE "[\\\/]debug([\\\/]lib[\\\/][^\\\/]+)$" "\\1" ${OutVar}_RELEASE "${${OutVar}}")

      # Call cmake method to merge the lib paths into a list
      string(REGEX REPLACE "^(.*)_LIBRARY" "\\1" Package "${OutVar}")
      select_library_configurations(${Package})

      # Update cache
      set(${OutVar} ${${OutVar}} CACHE INTERNAL "overwrite previously cached path" FORCE)

      # Update the flag so we won't do it again
      set(${OutVar}_FIXED 1 CACHE INTERNAL "lib path fixed")

      message(STATUS "[vcpkg] set ${OutVar} ${${OutVar}}")
    endif()
  endfunction()

  # Redefine _find_library - now the built-in find_library command would be __find_library
  function(_find_library)
    z_vcpkg_function_arguments(ARGS)
    message(STATUS "!!!_find_library ${ARGV0}")
    __find_library(${ARGS}) # CMake's built-in find_library command
  endfunction()

  # Helper function for custom find modules
  macro(overload_find_module Package)
    # Temporarily clear CMAKE_MODULE_PATH to load the original find module
    set(BACKUP_CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH})
    unset(CMAKE_MODULE_PATH)
    include(Find${Package})

    # Restore CMAKE_MODULE_PATH
    set(CMAKE_MODULE_PATH ${BACKUP_CMAKE_MODULE_PATH})
  endmacro()
endif()
