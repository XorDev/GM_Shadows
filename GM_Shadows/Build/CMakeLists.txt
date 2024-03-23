cmake_minimum_required(VERSION 3.6)

project(GM_Shadows)
set_directory_properties(PROPERTIES VS_STARTUP_PROJECT GM_Shadows)

set(project_root C:/Users/Jon/Documents/GitHub/GM_Shadows/GM_Shadows)

set(source ${CMAKE_CURRENT_SOURCE_DIR}/source.rsp)

# Load the script list, and remove the tildes from event scripts
file(STRINGS ${source} scriptList)
list(
  TRANSFORM scriptList
  REPLACE "~" ""
  OUTPUT_VARIABLE scriptPaths)

# Add the source list and each of the scripts to the project, so they appear in the IDE
add_custom_target(GM_Shadows ALL SOURCES ${source} ${scriptPaths})

# Create a source group hierarchy corresponding to the project's file structure
FOREACH(scriptPath ${scriptPaths})
  get_filename_component(scriptDirectory ${scriptPath} DIRECTORY)
  cmake_path(RELATIVE_PATH scriptDirectory BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} OUTPUT_VARIABLE relPath)
  # Remove the "../" from the beginning of the relative path
  string(REPLACE "../" "" filterPath ${relPath})
  source_group(${filterPath} FILES ${scriptPath})
ENDFOREACH()

set_target_properties(
  GM_Shadows PROPERTIES VS_DEBUGGER_COMMAND
                              ${CMAKE_CURRENT_BINARY_DIR}/GM_Shadows)

set_target_properties(GM_Shadows PROPERTIES OUTPUT_NAME "GM_Shadows")

# set_target_properties(GM_Shadows PROPERTIES
# VS_DEBUGGER_COMMAND_ARGUMENTS
# --wad=${CMAKE_CURRENT_BINARY_DIR}/GM_Shadows0.wad)

# FIXME :: Erin
#find_package(YYTools REQUIRED)

separate_arguments(GMC_ARGS)

if(DEBUG)
  add_custom_command(
    TARGET GM_Shadows
    COMMAND
      "${YY_DEBUG_TOOLS_DIR}/gmcd" -g -di -bd="${CMAKE_CURRENT_BINARY_DIR}/out" ${GMC_ARGS} -t ${TRIPLE_NAME}
      @${source} -l "${YY_DEBUG_LIBS_DIR}/${TRIPLE_NAME}" -l "${CMAKE_CURRENT_SOURCE_DIR}" -o
      "${CMAKE_CURRENT_BINARY_DIR}/GM_Shadows"
    COMMENT "Building Executable")
else()
  add_custom_command(
    TARGET GM_Shadows
    COMMAND
      "${YY_RELEASE_TOOLS_DIR}/gmc" -di -bd="${CMAKE_CURRENT_BINARY_DIR}/out" ${GMC_ARGS} -t ${TRIPLE_NAME}
      @${source} -l "${YY_RELEASE_LIBS_DIR}/${TRIPLE_NAME}" -l "${CMAKE_CURRENT_SOURCE_DIR}" -o
      "${CMAKE_CURRENT_BINARY_DIR}/GM_Shadows"
    COMMENT "Building Executable")
endif()
