cmake_minimum_required(VERSION 3.16)

project(snipper VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Widgets)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appsnipper
    src/main.cpp
)

qt_add_qml_module(appsnipper
    URI snipper
    QML_FILES
        qml/Main.qml
        qml/SelectionCanvas.qml
    SOURCES
        src/snipper_manager.h
        src/snipper_manager.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appsnipper PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appsnipper
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_include_directories(appsnipper PRIVATE src)

target_link_libraries(appsnipper
    PRIVATE Qt6::Quick
)
target_link_libraries(appsnipper PRIVATE Qt6::Widgets)

include(GNUInstallDirs)
install(TARGETS appsnipper
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
