-- PokeTag local profile.
-- This file is loaded after all OTClient modules are initialized.

local function configurePokeTagLocal()
  if not EnterGame then
    return
  end

  g_settings.set('host', '127.0.0.1')
  g_settings.set('port', 7171)
  g_settings.set('client-version', 854)
  g_settings.set('httpLogin', false)
  g_settings.set('autologin', false)

  EnterGame.setUniqueServer('127.0.0.1', 7171, 854)
  EnterGame.setHttpLogin(false)
end

addEvent(configurePokeTagLocal)
