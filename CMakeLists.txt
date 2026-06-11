cmake_minimum_required(VERSION 3.21)

project(FungerGames VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

find_package(Qt6 6.9 REQUIRED COMPONENTS Core Quick Qml Network)

qt_standard_project_setup(REQUIRES 6.9)

add_subdirectory(app)
add_subdirectory(iot-services/face-tracking-service)
add_subdirectory(iot-services/fridge-service)
