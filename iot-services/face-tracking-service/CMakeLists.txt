qt_add_executable(face-tracking-service
    main.cpp
    FaceTrackingServer.cpp
)

target_include_directories(face-tracking-service PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(face-tracking-service
    PRIVATE
        Qt6::Core
        Qt6::Network
)
