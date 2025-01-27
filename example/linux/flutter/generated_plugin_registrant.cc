//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <structify/structify_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) structify_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "StructifyPlugin");
  structify_plugin_register_with_registrar(structify_registrar);
}
