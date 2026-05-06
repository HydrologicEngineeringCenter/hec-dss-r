# hecdss.dll / libhecdss.so ship alongside hecdssr.dll / hecdssr.so in
# <pkg>/libs[/<arch>], so the dynamic loader finds them without any PATH
# manipulation:
#   * Windows: same-directory DLL search (inst/libs/x64/ → <pkg>/libs/x64/)
#   * Linux:   $ORIGIN rpath baked in by src/Makevars
# No .onLoad hook is required.
