qt_add_executable(FungerGames
    main.cpp
    src/TelemetryClient.cpp
    src/AppController.cpp
    qml.qrc
)

target_include_directories(FungerGames PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)

target_link_libraries(FungerGames
    PRIVATE
        Qt6::Core
        Qt6::Quick
        Qt6::Qml
        Qt6::Network
        Qt6::Multimedia
)
