cmake_minimum_required(VERSION 3.16)

project(snipper VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# TODO: Linux support
set(PLATFORM_RESOURCES "")

if(WIN32)
    set(PLATFORM_RESOURCES "${CMAKE_CURRENT_SOURCE_DIR}/windows_app_icon.rc")
endif()

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS QuickControls2)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_resources(RESOURCES resources.qrc)
qt_add_executable(appsnipper src/main.cpp ${RESOURCES} ${PLATFORM_RESOURCES})

set_source_files_properties(qml/Style.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
set_source_files_properties(qml/Icons.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(appsnipper
    URI snipper
    QML_FILES
        qml/Main.qml
        qml/Style.qml
        qml/Icons.qml
        # Components
        qml/components/Toast.qml

        qml/components/layouts/Titlebar.qml
        qml/components/layouts/SnippingOverlayToolbar.qml

        qml/components/overlays/SnippingOverlay.qml
        qml/components/overlays/CountdownOverlay.qml
        qml/components/overlays/ColorPickerOverlay.qml

        qml/components/ui/WindowToolButton.qml
        qml/components/ui/DropdownMenu.qml
        qml/components/ui/DropdownMenuItem.qml

        qml/components/window/FloatingImageWindow.qml
        qml/components/window/WindowResizeHandlers.qml
        # Pages
        qml/pages/PalettePage.qml
        qml/pages/MainPage.qml
    SOURCES
        src/core/snipper_manager.h src/core/snipper_manager.cpp
        src/core/colorhistory.h src/core/colorhistory.cpp
        src/core/navigator.hpp
        src/window/window_manager.h src/window/window_manager.cpp
        src/state/app_state.hpp src/state/app_settings.hpp
    RESOURCES
        resources.qrc
        QML_FILES qml/components/ui/BaseButton.qml
        RESOURCES windows_app_icon.rc
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

target_include_directories(appsnipper PRIVATE src src/core src/window src/state)

target_link_libraries(appsnipper PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
)

include(GNUInstallDirs)
install(TARGETS appsnipper
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
