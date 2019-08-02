project('com.github.artemanufrij.trimdown', 'vala', 'c', version: '1.0.0')

i18n = import('i18n')
gnome = import('gnome')

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

c_args = [
  '-include', 'config.h'
]

subdir('src')

executable(
    meson.project_name(),
    sources,
    c_args: c_args,
    dependencies: [
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('gtksourceview-3.0'),
        meson.get_compiler('vala').find_library('posix')
    ],
    install : true
)

subdir('data')
subdir('po')
subdir('schemas')

meson.add_install_script('meson/post_install.py')
