#!/usr/bin/env python3

import os
import subprocess

prefix = os.environ.get('MESON_INSTALL_PREFIX', '/usr/local')

schemadir = os.path.join(prefix, 'share', 'glib-2.0', 'schemas')
datadir = os.path.join(prefix, 'share')

if not os.environ.get('DESTDIR'):
	print('Compiling gsettings schemas...')
	subprocess.call(['glib-compile-schemas', schemadir])

	print('Updating icon cache...')
	icon_cache_dir = os.path.join(datadir, 'icons', 'hicolor')
	if not os.path.exists(icon_cache_dir):
		os.makedirs(icon_cache_dir)
	subprocess.call(['gtk-update-icon-cache', '-qtf', icon_cache_dir])