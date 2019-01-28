#!/usr/bin/env ruby

require 'json'
require_relative '../lib/karabiner.rb'
require_relative 'emacs_key_bindings.json'

$m_emacs = [
  *control_keys(
    :type => :generic,
    :description => 'wataash2: Emacs key bindings [left_control+keys]',
    :frontmost_application_unless => [Karabiner.frontmost_application_unless(['emacs', 'terminal', 'vi'])],
    :frontmost_application_if => []
  )['manipulators'],
  *option_keys(
    :type => :generic,
    :description => 'wataash2: Emacs key bindings [left_option+keys]',
    :frontmost_application_unless => [Karabiner.frontmost_application_unless(['emacs', 'terminal', 'vi'])],
    :frontmost_application_if => []
  )['manipulators'],
  *bash_style(
    :type => :generic,
    :description => 'wataash2: Bash style Emacs key bindings',
    :frontmost_application_unless => [Karabiner.frontmost_application_unless(['emacs', 'terminal', 'vi'])],
    :frontmost_application_if => []
  )['manipulators'],
]

$m_emacs = $m_emacs.map do |m|
  if m['from']['modifiers']['mandatory'] == ['control']
    m['from']['modifiers']['mandatory'] = ['left_control']
    # allow any optional modifiers
    # https://pqrs.org/osx/karabiner/json.html#from-event-definition-modifiers
    # > Events are also manipulated even if optional modifiers are pressed.
    # > Optional modifiers are kept in to events.
    # example: enable ctrl+cmd+option+shift+A -> cmd+option+shift+Home
    m['from']['modifiers']['optional'] = ['any']
  elsif m['from']['modifiers']['mandatory'] == ['option']
    m['from']['modifiers']['mandatory'] = ['left_option']
  else
    raise 'unexpected mandatory-modifiers'
  end

  m
end

$m_emacs.append(
  type: 'basic',
  from: {
    key_code: 'g',
    modifiers: Karabiner.from_modifiers(['left_control'], ['any']),
  },
  to: [{ key_code: 'escape' }],
  conditions: [Karabiner.frontmost_application_unless(['emacs', 'terminal', 'vi'])],
)

$m_emacs.append(
  type: 'basic',
  from: {
    key_code: 'j',
    modifiers: Karabiner.from_modifiers(['left_control'], ['any']),
  },
  to: [{ key_code: 'return_or_enter' }],
  conditions: [Karabiner.frontmost_application_unless(['emacs', 'terminal', 'vi'])],
)

# puts JSON.pretty_generate($m_emacs)


$m = [
=begin
  # ---------------------------------------------------------------------------
  # terminal: left_control<->right_control left_option<->right_option
  # to avoid emacs_key_bindings.json
  # c.f. remote-desktop.json, ag iterm
  {
    type: 'basic',
    from: { key_code: 'left_control', modifiers: { optional: ['any'] } },
    to: [{ key_code: 'right_control' }],
    conditions: [{ "type": "frontmost_application_if", "bundle_identifiers": ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"] }],
  },
  {
    type: 'basic',
    from: { key_code: 'right_control', modifiers: { optional: ['any'] } },
    to: [{ key_code: 'left_control' }],
    conditions: [{ "type": "frontmost_application_if", "bundle_identifiers": ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"] }],
  },
  {
    type: 'basic',
    from: { key_code: 'left_option', modifiers: { optional: ['any'] } },
    to: [{ key_code: 'right_option' }],
    conditions: [{ "type": "frontmost_application_if", "bundle_identifiers": ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"] }],
  },
  {
    type: 'basic',
    from: { key_code: 'right_option', modifiers: { optional: ['any'] } },
    to: [{ key_code: 'left_option' }],
    conditions: [{ "type": "frontmost_application_if", "bundle_identifiers": ["^com\\.apple\\.Terminal$", "^com\\.googlecode\\.iterm2$"] }],
  },
=end
# ---------------------------------------------------------------------------
# JerBrains: ctrl+shift+[ae] → shift+{home,end}
# Java GUIなのでmacOSのemacsキーバインドは独自解釈するっぽい
  {
    type: 'basic',
    from: {
      key_code: 'e',
      # modifiers: { mandatory: ['left_control', 'shift'], optional: ['any'] },
      modifiers: Karabiner.from_modifiers(['left_control', 'shift'], ['any'])
    },
    to: [{ key_code: 'end', modifiers: ['left_shift'] }],
    conditions: [Karabiner.frontmost_application_if(['jetbrains_ide'])],
  },
  {
    type: 'basic',
    from: {
      key_code: 'a',
      modifiers: Karabiner.from_modifiers(['left_control', 'shift'], ['any'])
    },
    to: [{ key_code: 'home', modifiers: ['left_shift'] }],
    conditions: [Karabiner.frontmost_application_if(['jetbrains_ide'])],
  },
  # ---------------------------------------------------------------------------
  # ---------- ^^^^^^^^^^ based on @tekezo
  {
    type: 'basic',
    from: {
      key_code: 'hyphen',
      modifiers: Karabiner.from_modifiers(['left_control'], ['caps_lock']),
    },
    to: 9.times.map { { key_code: 'hyphen' } }.append({ key_code: 'hyphen', repeat: false }),
  },
  {
    type: 'basic',
    from: {
      key_code: 'equal_sign',
      modifiers: Karabiner.from_modifiers(['left_control'], ['caps_lock']),
    },
    to: 9.times.map { { key_code: 'equal_sign' } }.append({ key_code: 'equal_sign', repeat: false }),
  },
  # with shift: 70 chars
  {
    type: 'basic',
    from: {
      key_code: 'hyphen',
      modifiers: Karabiner.from_modifiers(['left_control', 'shift'], ['caps_lock']),
    },
    to: 69.times.map { { key_code: 'hyphen' } }.append({ key_code: 'hyphen', repeat: false }),
  },
  {
    type: 'basic',
    from: {
      key_code: 'equal_sign',
      modifiers: Karabiner.from_modifiers(['left_control', 'shift'], ['caps_lock']),
    },
    to: 69.times.map { { key_code: 'equal_sign' } }.append({ key_code: 'equal_sign', repeat: false }),
  },
  # ---------------------------------------------------------------------------
  # Launch apps by [right_option]+letters
  { type: 'basic', from: { key_code: 'a', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open '/Applications/Atom.app'" }] },
  { type: 'basic', from: { key_code: 'b', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "---------- TODO ----------" }] },
  { type: 'basic', from: { key_code: 'c', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open ~/Applications/'JetBrains Toolbox'/CLion.app" }] },
  { type: 'basic', from: { key_code: 'd', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open ~/Desktop" }] },
  { type: 'basic', from: { key_code: 'e', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open '/Applications/Evernote.app'" }] },
  { type: 'basic', from: { key_code: 'f', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open ~" }] },
  { type: 'basic', from: { key_code: 'g', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open ~/Applications/'JetBrains Toolbox'/GoLand.app" }] },
  { type: 'basic', from: { key_code: 'h', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open '/Applications/HipChat.app'" }] },
  { type: 'basic', from: { key_code: 'i', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open '/Applications/iTerm.app'" }] },
  { type: 'basic', from: { key_code: 'j', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "---------- TODO ----------" }] },
  { type: 'basic', from: { key_code: 'k', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open '/Applications/kdiff3.app'" }] },
  { type: 'basic', from: { key_code: 'k', modifiers: Karabiner.from_modifiers(['right_option', 'shift'], ['caps_lock']) },
    to: [{ shell_command: "open '/Applications/Karabiner-Elements.app'" }] },
  { type: 'basic', from: { key_code: 'l', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "---------- TODO ----------" }] },
  { type: 'basic', from: { key_code: 'm', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "---------- TODO ----------" }] },
  { type: 'basic', from: { key_code: 'n', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "---------- TODO ----------" }] },
  { type: 'basic', from: { key_code: 'o', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "---------- TODO ----------" }] },
  { type: 'basic', from: { key_code: 'p', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open ~/Applications/'JetBrains Toolbox'/'PyCharm Professional'.app" }] },
  { type: 'basic', from: { key_code: 'q', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "---------- TODO ----------" }] },
  { type: 'basic', from: { key_code: 'r', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open ~/Applications/'JetBrains Toolbox'/RubyMine.app" }] },
  { type: 'basic', from: { key_code: 's', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open '/Applications/Sublime Text.app'" }] },
  { type: 'basic', from: { key_code: 's', modifiers: Karabiner.from_modifiers(['right_option', 'shift'], ['caps_lock']) },
    to: [{ shell_command: "open '/Applications/Station.app'" }] },
  { type: 'basic', from: { key_code: 't', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open '/Applications/Thunderbird.app'" }] },
  { type: 'basic', from: { key_code: 'u', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "---------- TODO ----------" }] },
  { type: 'basic', from: { key_code: 'v', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open '/Applications/Visual Studio Code.app'" }] },
  { type: 'basic', from: { key_code: 'w', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "open '/Applications/Google Chrome.app'" }] },
  { type: 'basic', from: { key_code: 'x', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "---------- TODO ----------" }] },
  { type: 'basic', from: { key_code: 'y', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "---------- TODO ----------" }] },
  { type: 'basic', from: { key_code: 'z', modifiers: Karabiner.from_modifiers(['right_option'], ['caps_lock']) },
    to: [{ shell_command: "---------- TODO ----------" }] },
# ---------------------------------------------------------------------------
]

def main
  puts JSON.pretty_generate(
    title: 'Personal rules (@wataash2)',
    rules: [
      {
        description: 'wataash2: misc',
        manipulators: $m + $m_emacs,
      },
    ] # rules
  )
end

main
