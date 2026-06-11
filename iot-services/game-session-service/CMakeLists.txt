qt_add_executable(game-session-service
    main.cpp
    GameSessionServer.cpp
)

target_include_directories(game-session-service PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(game-session-service
    PRIVATE
        Qt6::Core
        Qt6::Network
)
