project('com.github.artemanufrij.trimdown', ['vala', 'c'],
        version: '1.0.0')

i18n = import('i18n')
gnome = import('gnome')

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

c_args = [
  '-include', 'config.h'
]

deps = [
  dependency('granite'),
  dependency('gtk+-3.0'),
  dependency('gtksourceview-3.0'),
  meson.get_compiler('vala').find_library('posix')
]

#asresources = gnome.compile_resources(
#    'as-resources', 'schemas/' + meson.project_name() + '.gresource.xml',
#    source_dir: 'schemas',
#    c_name: 'as'
#)

executable(
    meson.project_name(),
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/Settings.vala',
    'src/Objects/BaseObject.vala',
    'src/Objects/Scene.vala',
    'src/Objects/Note.vala',
    'src/Objects/Chapter.vala',
    'src/Objects/Project.vala',
    'src/Widgets/Scene.vala',
    'src/Widgets/SceneList.vala',
    'src/Widgets/Note.vala',
    'src/Widgets/Notes.vala',
    'src/Widgets/Chapter.vala',
    'src/Widgets/ChapterList.vala',
    'src/Widgets/Views/Writer.vala',
    'src/Widgets/Views/Welcome.vala',
    'src/Dialogs/NewProject.vala',
    'src/Services/ProjectManager.vala',
    'src/Utils/Utils.vala',

 #   asresources,
    c_args: c_args,
    dependencies: [
        deps
    ],
    install : true
)

meson.add_install_script('meson/post_install.py')

subdir('schemas')
subdir('data')
#subdir('po')
