project('fbink', 'c', version: '1.25.0')

cc = meson.get_compiler('c')

m_dep = cc.find_library('m', required: false)

target = get_option('target')
if target == ''
  target = host_machine.system()
endif

c_args = [
  '-D_REENTRANT=1',
  '-D_GNU_SOURCE',
  '-DFBINK_MINIMAL',
  '-DFBINK_FOR_' + target.to_upper(),
  '-DFBINK_VERSION="' + meson.project_version() + ' for ' + get_option('target') +
  '"',
]

src = [
  'cutef8/dfa.c',
  'cutef8/utf8.c',
  'fbink.c',
]

draw_opt = get_option('draw')
if draw_opt.allowed()
  c_args += '-DFBINK_WITH_DRAW'
endif

bitmap_opt = get_option(
  'bitmap',
).require(
  draw_opt.allowed(),
  error_message: 'needs the draw feature',
)
if bitmap_opt.allowed()
  c_args += '-DFBINK_WITH_BITMAP'
endif

button_scan_opt = get_option(
  'button-scan',
).require(
  target in ['Cervantes', 'Kobo'],
  error_message: 'is only supported for the Cervantes and Kobo targets',
).require(
  draw_opt.allowed(),
  error_message: 'needs the draw feature',
)
if button_scan_opt.allowed()
  c_args += '-DFBINK_WITH_BUTTON_SCAN'
endif

fonts_opt = get_option(
  'fonts',
).require(
  bitmap_opt.allowed(),
  error_message: 'needs the bitmap feature',
)
if fonts_opt.allowed()
  c_args += '-DFBINK_WITH_FONTS'
endif

image_opt = get_option(
  'image',
).require(
  draw_opt.allowed(),
  error_message: 'needs the draw feature',
)
if image_opt.allowed()
  c_args += '-DFBINK_WITH_IMAGE'
  src += 'qimagescale/qimagescale.c'
endif

inputlib_opt = get_option('inputlib')
if inputlib_opt.allowed()
  c_args += '-DFBINK_WITH_INPUT'
endif

opentype_opt = get_option(
  'opentype',
).require(
  draw_opt.allowed(),
  error_message: 'needs the draw feature',
)
if opentype_opt.allowed()
  c_args += '-DFBINK_WITH_OPENTYPE'
  src += [
    'libunibreak/src/eastasianwidthdef.c',
    'libunibreak/src/linebreak.c',
    'libunibreak/src/linebreakdata.c',
    'libunibreak/src/linebreakdef.c',
    'libunibreak/src/unibreakdef.c',
  ]
endif

if target == 'Kobo'
  src += 'i2c-tools/lib/smbus.c'
endif

fbink_static_lib = static_library(
  'fbink',
  src,
  c_args: c_args,
  dependencies: m_dep,
  include_directories: include_directories(
    'i2c-tools/include',
  ),
)

fbink_shared_lib = shared_library(
  'fbink',
  src,
  c_args: c_args + '-DFBINK_SHAREDLIB',
  dependencies: m_dep,
  include_directories: include_directories(
    'i2c-tools/include',
  ),
)

fbink_dep = declare_dependency(
  include_directories: '.',
  link_with: fbink_static_lib,
)

meson.override_dependency('fbink', fbink_dep)

fbink_opt = get_option(
  'fbink',
).require(
  bitmap_opt.allowed(),
  error_message: 'needs the bitmap feature',
)
if fbink_opt.allowed()
  executable(
    'fbink',
    'fbink_cmd.c',
    c_args: c_args,
    include_directories: include_directories(
      'i2c-tools/include',
    ),
    install: true,
    link_with: fbink_static_lib,
  )
endif

if inputlib_opt.allowed()
  fbink_input_lib = library(
    'fbink_input',
    'fbink_input_scan.c',
    c_args: c_args + '-DFBINK_INPUT_LIB' + (
      get_option('default_library') == 'shared' ? '-DFBINK_SHAREDLIB' : []
    ) + cc.get_supported_arguments('-Wno-unused-function'),
    install: true,
  )
  fbink_input_dep = declare_dependency(
    include_directories: '.',
    link_with: fbink_input_lib,
  )
  meson.override_dependency('fbink_input', fbink_input_dep)
endif

fbdepth_opt = get_option('fbdepth')
if fbdepth_opt.allowed()
  executable(
    'fbdepth',
    'utils/fbdepth.c',
    c_args: c_args,
    install: true,
    link_with: fbink_static_lib,
  )
endif

fbink_input_scan_opt = get_option('input_scan')
if fbink_input_scan_opt.allowed()
  executable(
    'input_scan',
    'utils/input_scan.c',
    c_args: c_args,
    install: true,
    link_with: fbink_static_lib,
  )
endif

summary(
  {
    'Bitmap'       : bitmap_opt.allowed(),
    'Button scan'  : button_scan_opt.allowed(),
    'Draw'         : draw_opt.allowed(),
    'Fonts'        : fonts_opt.allowed(),
    'Image'        : image_opt.allowed(),
    'Input library': inputlib_opt.allowed(),
    'OpenType'     : opentype_opt.allowed(),
    'Target'       : get_option('target'),
    'Tools'        : ', '.join(
      fbdepth_opt.allowed() ? 'fbdepth' : [],
      fbink_opt.allowed() ? 'fbink' : [],
    ),
  },
  bool_yn: true,
)