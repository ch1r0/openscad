include("${CMAKE_SOURCE_DIR}/vcpkg.cmake")
overload_find_module(PkgConfig)

# Override _pkg_check_modules_internal from the original FindPkgConfig.cmake
macro(_pkg_check_modules_internal _is_required _is_silent _no_cmake_path _no_cmake_environment_path _imp_target _imp_target_global _prefix)
  if (NOT _no_cmake_path)
    # Backup CMAKE_PREFIX_PATH
    set(CMAKE_PREFIX_PATH_vcpkg_OLD ${CMAKE_PREFIX_PATH})

    # For vcpkg - run pkg-config twice for each package - one for debug one for release. Then combine the list of libraries.
    unset(_tmpLinkLibraries)

    foreach (_prefixPath ${CMAKE_PREFIX_PATH_vcpkg_OLD})
      unset(${_prefix}_LINK_LIBRARIES)

      # vcpkg has separate debug/release directories in CMAKE_PREFIX_PATH. Call _pkg_check_modules_internal on each of them separately.
      set(CMAKE_PREFIX_PATH ${_prefixPath})
      message(STATUS "[vcpkg] _pkg_check_modules_internal(${_prefix}): CMAKE_PREFIX_PATH = ${CMAKE_PREFIX_PATH}")

      # Call original macro
      __pkg_check_modules_internal(${_is_required} ${_is_silent} ${_no_cmake_path} ${_no_cmake_environment_path} ${_imp_target} ${_imp_target_global} "${_prefix}" ${ARGN})

      message(STATUS "[vcpkg] _pkg_check_modules_internal(${_prefix}): ${_prefix}_LINK_LIBRARIES = ${${_prefix}_LINK_LIBRARIES}")

      # Determine config type based on current prefix path
      set(_tmpConfig "optimized")
      if (_prefixPath MATCHES "[\\\/]debug$")
        set(_tmpConfig "debug")
      endif()

      # Merge libraries into final list
      foreach (_path ${${_prefix}_LINK_LIBRARIES})
        list(FIND _tmpLinkLibraries "${_path}" _tmpIndex)
        if (${_tmpIndex} EQUAL -1)
          list(APPEND _tmpLinkLibraries "${_tmpConfig}" "${_path}")
	endif()
      endforeach()
    endforeach()

    # Restore CMAKE_PREFIX_PATH
    set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH_vcpkg_OLD})

    # Copy final list to out variable
    set(${_prefix}_LINK_LIBRARIES ${_tmpLinkLibraries})
  else()
    # Call original macro
    __pkg_check_modules_internal(${_is_required} ${_is_silent} ${_no_cmake_path} ${_no_cmake_environment_path} ${_imp_target} ${_imp_target_global} "${_prefix}" ${ARGN})
  endif()
endmacro()
