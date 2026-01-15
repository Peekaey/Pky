defmodule PkyWeb.Live.CursorTracking.CursorUtils do
  @moduledoc """
  Returns a random name/color to identify users cursor
  """
  
  @colors ~w(
    #FF5733 #33FF57 #3357FF #F333FF #33FFF5 #F5FF33
    #FF0055 #00FFCC #CCFF00 #AA00FF #FF9900 #0099FF
    #FF33A8 #A833FF #33FF99 #FF5733 #57FF33 #5733FF
    #FFD700 #00CED1
  )
  @names ~w(
    AnonymousBadger MysteryMoose HiddenHawk SilentSquid IncognitoIguana
    SecretSquirrel PhantomPanda GhostlyGecko ShadowShark CosmicCat
    DigitalDuck ElectricEagle GlitchyGoat HollowHyena InvisibleIbis
    JumpyJellyfish KineticKangaroo LonelyLemur MysticMantis NebulaNarwhal
    OrbitingOwl PixelPenguin QuantumQuail RadarRabbit StealthySeal
    TurboTiger UnknownUrchin VirtualViper WanderingWolf XenonXerus
    BinaryBat CipherCobra DataDolphin EncryptedElk FirewallFox
    HoloHamster InfinityImp LogicLynx MemoryMouse NullNewt
    OfflineOtter ProxyParrot RebootRacoon SignalSwan TerminalToad
    UserUnicorn VPNVulture WifiWeasel ZeroZebra
  )
  @spec random_color :: String.t()
  def random_color, do: Enum.random(@colors)
  @spec random_name :: String.t()
  def random_name, do: Enum.random(@names)
end
