qt_add_executable(device-status-service
    main.cpp
    DeviceStatusServer.cpp
)

target_include_directories(device-status-service PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(device-status-service
    PRIVATE
        Qt6::Core
        Qt6::Network
)
