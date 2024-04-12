
add_executable(make-files)

target_compile_definitions(make-files PRIVATE
    WIN32_LEAN_AND_MEAN
    NOMINMAX
    )

target_compile_features(make-files PRIVATE
    cxx_std_23
    )

target_compile_options(make-files PRIVATE
    /W4
    /WX
    /permissive-
    )

target_sources(make-files PRIVATE
    main.cpp
    )
