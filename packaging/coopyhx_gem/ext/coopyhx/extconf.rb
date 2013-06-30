require 'mkmf'

puts Dir.pwd
find_header('coopyhx_rb.h', 'include', 'coopyhx/include')

$defs.push("-DHX_LINUX -DHXCPP_M64 -DHXCPP_VISIT_ALLOCS -Dhaxe3")

create_makefile('coopyhx/coopyhx')
