set(LIBTENSORFLOWLITE_VERSION 2.14.0)

option(TENSORFLOWLITE_ROOTDIR "tensorflowlite root dir")
set(TENSORFLOWLITE_ROOTDIR ${CMAKE_CURRENT_SOURCE_DIR}/modules/tensorflowlite-${LIBTENSORFLOWLITE_VERSION})

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/modules/tensorflowlite-${LIBTENSORFLOWLITE_VERSION}/)
    message(STATUS "Tensorflow Lite library found at /modules/tensorflowlite-${LIBTENSORFLOWLITE_VERSION}")
else()
    file(MAKE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/modules/tensorflowlite-${LIBTENSORFLOWLITE_VERSION}/)
    message(STATUS "Tensorflow Lite library not found - downloading pre-built library.")

    if(WIN32)
        set(LIB_TENSORFLOWLITE_PRE_BUILD_LIB_NAME "tensorflowlite_c-${LIBTENSORFLOWLITE_VERSION}-Windows")
    endif()

    if(UNIX AND NOT APPLE)
        set(LIB_TENSORFLOWLITE_PRE_BUILD_LIB_NAME "tensorflowlite_c-${LIBTENSORFLOWLITE_VERSION}-Linux")
    endif()

    if(UNIX AND APPLE)
        if (CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64")
            set(LIB_TENSORFLOWLITE_PRE_BUILD_LIB_NAME "tensorflowlite_c-${LIBTENSORFLOWLITE_VERSION}-macOS-x86_64")
        elseif (CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "arm64")
            set(LIB_TENSORFLOWLITE_PRE_BUILD_LIB_NAME "tensorflowlite_c-${LIBTENSORFLOWLITE_VERSION}-macOS-arm64")
        else()
            message(FATAL_ERROR "CMAKE_HOST_SYSTEM_PROCESSOR not defined.")
        endif()
    endif()

    set(LIBTENSORFLOWLITE_URL https://github.com/faressc/tflite-c-lib/releases/download/v${LIBTENSORFLOWLITE_VERSION}/${LIB_TENSORFLOWLITE_PRE_BUILD_LIB_NAME}.zip)
    message(STATUS "Downloading ${LIBTENSORFLOWLITE_URL}")
    set(LIBTENSORFLOWLITE_PATH ${CMAKE_BINARY_DIR}/import/${LIB_TENSORFLOWLITE_PRE_BUILD_LIB_NAME}.zip)

    file(DOWNLOAD ${LIBTENSORFLOWLITE_URL} ${LIBTENSORFLOWLITE_PATH} STATUS LIBTENSORFLOWLITE_DOWNLOAD_STATUS SHOW_PROGRESS)
    list(GET LIBTENSORFLOWLITE_DOWNLOAD_STATUS 0 LIBTENSORFLOWLITE_DOWNLOAD_STATUS_NO)

    file(ARCHIVE_EXTRACT
            INPUT ${CMAKE_BINARY_DIR}/import/${LIB_TENSORFLOWLITE_PRE_BUILD_LIB_NAME}.zip
            DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/modules/tensorflowlite-${LIBTENSORFLOWLITE_VERSION}/)

    file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/modules/tensorflowlite-${LIBTENSORFLOWLITE_VERSION}/${LIB_TENSORFLOWLITE_PRE_BUILD_LIB_NAME}/ DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/modules/tensorflowlite-${LIBTENSORFLOWLITE_VERSION}/)

    file(REMOVE_RECURSE ${CMAKE_CURRENT_SOURCE_DIR}/modules/tensorflowlite-${LIBTENSORFLOWLITE_VERSION}/${LIB_TENSORFLOWLITE_PRE_BUILD_LIB_NAME})

    if(LIBtensorflowlite_DOWNLOAD_STATUS_NO)
        message(STATUS "Pre-built library not downloaded. Error occurred, try again and check cmake/SetupTensorflowLite.cmake")
        file(REMOVE_RECURSE ${CMAKE_CURRENT_SOURCE_DIR}/modules/tensorflowlite-${LIBTENSORFLOWLITE_VERSION})
        file(REMOVE ${LIBTENSORFLOWLITE_PATH})
    else()
        message(STATUS "Linking downloaded TensorflowLite pre-built library.")
    endif()
endif()

include_directories(SYSTEM
    "${TENSORFLOWLITE_ROOTDIR}/include"
)

link_directories(
    "${TENSORFLOWLITE_ROOTDIR}/lib"
)