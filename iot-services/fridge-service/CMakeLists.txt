qt_add_executable(fridge-service
    main.cpp
    FridgeServiceServer.cpp
)

target_include_directories(fridge-service PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(fridge-service
    PRIVATE
        Qt6::Core
        Qt6::Network
)
