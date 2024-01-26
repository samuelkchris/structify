#include "include/structify/structify_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "structify_plugin.h"

void StructifyPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  structify::StructifyPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
