# filename: resolve_duplicate_filename.cmake
#
# dependency: resolve_duplicate_filename_alias.cmake.in
#
# This funciton resolves filename collisions by identifying all collisions in the
# input source list (variable) and replacing duplicate filenames with a new alias
# source file in the build directory using a filename constructed from the
# original file's basename and the SHA1 of the file contents, roughly:
#
# ${CMAKE_CURRENT_LIST}/${file1}.${ext} ->
#     ${CMAKE_CURRENT_BINARY_DIR}/${file1}_${file1_sha1}.${ext}
#
# This function can be used as a workaround for CMake + Xcode generator OBJECT
# library shortcomings described here:
#
# http://cmake.3232098.n2.nabble.com/OBJECT-Libraries-with-Xcode-Generator-td7593197.html

function(resolve_duplicate_filenames sources file_regex)

  return() # not needed for static libs

  list(LENGTH ${sources} sources_count)

  # Only two or more files can result in a collision
  if(${sources_count} LESS 2)
    return()
  endif()

  message("resolving : ${sources} w/ ${file_regex}")
  
  # first create a list of basenames from which to detect collisions
  set(basenames "")
  foreach(filename ${${sources}})
    get_filename_component(basename ${filename} NAME_WE)
    list(APPEND basenames "${basename}")
  endforeach()
  
  # enumerate all pairs and check for collisions
  math(EXPR i_end "${sources_count}-2")
  math(EXPR j_end "${sources_count}-1")
  foreach(i RANGE 0 ${i_end})

    # SHA1 requires full paths as of https://gitlab.kitware.com/cmake/cmake/merge_requests/1292#note_323345        
    list(GET ${sources} ${i} i_path)
    if((NOT ("${i_path}" MATCHES "${file_regex}")) OR (NOT EXISTS "${i_path}"))
      continue()
    endif()
    
    get_filename_component(i_full "${i_path}" REALPATH)
    file(SHA1 "${i_full}" i_sha1)
    list(GET basenames ${i} i_name)    
    
    math(EXPR j_start "${i}+1")
    foreach(j RANGE ${j_start} ${j_end})

      list(GET ${sources} ${j} j_path)
      if((NOT ("${j_path}" MATCHES "${file_regex}")) OR (NOT EXISTS "${j_path}"))
        continue()
      endif()
      
      get_filename_component(j_full "${j_path}" REALPATH)
      file(SHA1 ${j_full} j_sha1)
      list(GET basenames ${j} j_name)    

      string(COMPARE EQUAL "${i_name}" "${j_name}" are_equal)
      if(${are_equal})

        # construct a relative_dir + name  (without extensions)
        file(RELATIVE_PATH j_relative "${CMAKE_SOURCE_DIR}" ${j_path})
        get_filename_component(j_dir ${j_relative} DIRECTORY)
        get_filename_component(j_ext ${j_relative} EXT)
        set(j_duplicate "${CMAKE_BINARY_DIR}/${j_dir}/${j_name}_${j_sha1}${j_ext}")

        # Note: configure_file() will only generate the file as needed (when contents change)        
        # Required variables in filename_alias.cmake.in template:
        # * source_filename : the souce filename to be aliased
        set(source_filename "${j_full}")
        configure_file("resolve_duplicate_filenames_alias.cmake.in" "${j_duplicate}" @ONLY)

        message("Detected filename collision, adding alias filename ${j_duplicate} for ${j_path}")

        # Replace the original filename in the list with the new alias filename:
        math(EXPR j_plus_1 "${j} + 1")        
        list(INSERT ${sources} ${j} ${j_duplicate})
        list(REMOVE_AT ${sources} ${j_plus_1})        
      endif()
      
    endforeach()
  endforeach()

  # Return the patched list to the PARENT_SCOPE
  set(${sources} ${${sources}} PARENT_SCOPE)
    
endfunction()
